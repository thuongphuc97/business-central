page 50102 "Price Approval"
{
    ApplicationArea = All;
    Caption = 'Price Approval';
    PageType = Card;
    SourceTable = "Price Approval";
    PromotedActionCategories = 'Approval';
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            group(Generals)
            {
                group(Informations)
                {
                    field("Title"; Rec.Title)
                    {
                        ShowMandatory = true;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the comment field.';
                    }

                    field("User ID"; Rec."User ID")
                    {
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the comment field.';
                    }

                    field(Purpose; Rec.Purpose)
                    {
                        ShowMandatory = true;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Purpose field.';
                    }
                }
                group("Ticket Status")
                {
                    field(Status; Rec.Status)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Status field.';
                    }
                    field("Due Date"; Rec."Due Date")
                    {
                        ShowMandatory = true;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Due Date field.';
                    }
                }
            }
            field(addNewBtn; AddNewBtnLbl)
            {
                ApplicationArea = All;
                ShowCaption = false;
                trigger OnDrillDown()
                var
                    AddNew: Page "MaterialCardPage";
                    NewRec: Record "Material";
                begin
                    NewRec.Init();
                    NewRec.Code := Rec.No_;
                    NewRec.Insert();
                    AddNew.SetRecord(NewRec);
                    AddNew.Run();
                end;
            }
            part(Material; "MaterialTreeList")
            {
                ApplicationArea = All;
                SubPageLink = "Code" = FIELD("No_");
            }
            group("General explanation")
            {
                usercontrol(SMTEditor; "SMT Editor")
                {
                    ApplicationArea = All;
                    trigger ControlAddinReady()
                    begin
                        NewData := Rec.GetContent();
                        CurrPage.SMTEditor.InitializeSummerNote(NewData);
                    end;

                    trigger onBlur(Data: Text)
                    begin
                        NewData := Data;
                    end;
                }
            }
            group(Attachment) { }
        }
    }
    actions
    {

        area(Processing)
        {
            action(Update)
            {
                ApplicationArea = all;
                Image = WorkCenterLoad;
                Caption = 'Refresh Page';

                trigger OnAction()
                var
                    UpdatedLbl: Label 'Page Refreshed';
                begin
                    CurrPage.Material.Page.LoadOrders();
                    Message(UpdatedLbl);
                end;
            }
            action(NewMaterial)
            {
                Image = New;
                Caption = 'Add New Material';
                ApplicationArea = All;

                trigger OnAction()
                var
                    AddNew: Page "MaterialCardPage";
                    NewRec: Record "Material";
                begin

                    NewRec.Init();
                    NewRec.Code := Rec.No_;
                    NewRec.Insert();
                    AddNew.SetRecord(NewRec);
                    AddNew.Run();
                end;

            }
            group(Approval)
            {
                // Caption = 'Approval';
                Image = Approvals;
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested.';
                    Promoted = true;
                    Visible = OpenApprovalEntriesExistCurrUser;
                    trigger OnAction()
                    var
                        Question: Text;
                        Answer: Boolean;
                        Text000: Label 'Do you agree with this request?';
                    begin
                        Question := Text000;
                        Answer := Dialog.Confirm(Question, true, false);
                        if Answer = true then begin
                            ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                        end;
                    end;

                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;
                    trigger OnAction()
                    var
                        Question: Text;
                        Answer: Boolean;
                        Text000: Label 'Reject request?';
                    begin
                        Question := Text000;
                        Answer := Dialog.Confirm(Question, true, false);
                        if Answer = true then begin
                            ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                        end;
                    end;

                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;
                    trigger OnAction()

                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistCurrUser;
                    Promoted = true;

                    PromotedCategory = New;


                    trigger OnAction()
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = All;
                    Caption = 'Approvals History';
                    Image = Approvals;
                    ToolTip = 'View approval requests.';
                    Promoted = true;
                    PromotedCategory = Process; //!Show in toolbar
                    Visible = HasApprovalEntries;

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
            }

            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Visible = NOT OpenApprovalEntriesExist AND (p::Open = Rec."Status") OR (p::Rejected = Rec."Status");//! Could be use Enabled
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval to change the record.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        CustomWorkflowMgmt: Codeunit "Custom Workflow Mgmt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        if CustomWorkflowMgmt.CheckApprovalsWorkflowEnabled(RecRef) then
                            CustomWorkflowMgmt.OnSendWorkflowForApproval(RecRef);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Visible = CanCancelApprovalForRecord; //! Could be use Enabled
                    Image = CancelApprovalRequest;
                    ToolTip = 'Cancel the approval request.';
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        CustomWorkflowMgmt: Codeunit "Custom Workflow Mgmt";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        CustomWorkflowMgmt.OnCancelWorkflowForApproval(RecRef);
                    end;
                }
            }
        }
        area(Creation)
        {

        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."User ID" := Database.UserId();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
    end;


    trigger OnClosePage()
    begin
        Rec.TestField(Title);
        Rec.TestField("Due Date");
        Rec.TestField(Purpose);
        Rec.SetContent(NewData);
    end;

    trigger OnOpenPage()
    begin
        if (Rec."User ID" <> UserId) and (p::Open <> Rec."Status") and (p::Rejected <> Rec."Status") then
            CurrPage.Editable(false);
    end;

    var
        p: enum "Custom Approval Enum";
        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord
        , HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        DynamicEditable: Boolean;
        StatusStyleTxt: Text;
        EditorReady: Boolean;
        NewData: Text;
        AddNewBtnLbl: Label 'Add New Material';
}
