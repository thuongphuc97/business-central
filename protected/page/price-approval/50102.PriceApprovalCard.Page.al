page 50102 "Price Approval"
{
    Caption = 'Price Approval';
    RefreshOnActivate = true;
    PageType = Card;
    SourceTable = "Price Approval";
    PromotedActionCategories = 'Approval';
    // DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(Generals)
            {
                Editable = DynamicEditable;
                group(Informations)
                {
                    field("Title"; Rec.Title)
                    {
                        Editable = DynamicEditable;
                        ShowMandatory = true;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the comment field.';
                    }

                    field("User ID"; Rec.UserName)
                    {
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the comment field.';
                    }
                    field("Department"; Rec.Department)
                    {
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the comment field.';
                    }
                    field(Purpose; Rec.Purpose)
                    {
                        Editable = DynamicEditable;
                        ShowMandatory = true;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Purpose field.';
                    }
                }
                group("Ticket Status")
                {
                    field(Status; Rec.Status)
                    {
                        Editable = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Status field.';
                        StyleExpr = StatusStyleTxt;
                    }
                    field("Due Date"; Rec."Due Date")
                    {
                        Editable = DynamicEditable;
                        ShowMandatory = true;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Due Date field.';
                    }
                }
            }
            part(HTMLRender; "Material Html Rendering")
            {
                Editable = DynamicEditable;
                Visible = NOT Rec.ApprovalType;
                ApplicationArea = All;
            }
            part("General Material"; "General Material")
            {
                Editable = DynamicEditable;
                Visible = Rec.ApprovalType;
                ApplicationArea = All;
            }
            group("General explanation")
            {
                Editable = DynamicEditable;
                Visible = true;
                usercontrol(SMTEditor; "SMT Editor")
                {
                    Visible = DynamicEditable;
                    ApplicationArea = All;
                    trigger ControlAddinReady()
                    begin
                        NewData := Rec.GetContent();
                        CurrPage.SMTEditor.InitializeSummerNote(NewData, 'full');
                    end;

                    trigger onBlur(Data: Text)
                    begin
                        NewData := Data;
                    end;
                }
                usercontrol(htmlShow; HTML)
                {
                    ApplicationArea = All;
                    Visible = NOT DynamicEditable;
                    trigger ControlReady()
                    begin
                        NewData := Rec.GetContent();
                        If (NewData <> '') then
                            CurrPage.htmlShow.Render(NewData, false)
                        else
                            CurrPage.htmlShow.Render('<div class="grid-emptyrowmessage" style="display: block;"><span>(There is nothing to show in this view)</span></div>', false);
                    end;
                }
            }
            part(Collaborators; EmailCC)
            {
                Editable = DynamicEditable;
                Caption = 'Collaborators';
                ApplicationArea = All;
                SubPageLink = ApprovalID = field("NO_");
            }
            field(Attachments; 'Attachments')
            {
                ApplicationArea = All;
                ShowCaption = false;
                StyleExpr = 'Favorable';
                Caption = 'Attach files';
                Visible = DynamicEditable;
                trigger OnDrillDown()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }
            part("Attached Documents List"; "Document Attachment ListPart")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50105),
                              "No." = FIELD(No_);
            }

        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {

                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = CONST(50105),
                              "No." = FIELD(No_);
            }
        }

    }
    actions
    {
        area(Processing)
        {
            group(Approval)
            {
                Image = Approvals;
                action(onHold)
                {
                    Caption = 'On Hold';
                    ApplicationArea = All;
                    Image = Answers;
                    Promoted = true;
                    Visible = OpenApprovalEntriesExistCurrUser AND (REc.Status <> P::OnHold);
                    trigger OnAction()
                    begin
                        Rec.Status := p::OnHold;
                        Rec.Modify();
                    end;
                }
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
                    Visible = NOT OpenApprovalEntriesExist AND ((p::Open = Rec."Status") OR (p::Rejected = Rec."Status")) AND CanRequestApprovalForRecord;//! Could be use Enabled
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
                        SetEditStatus();
                        CurrPage.Update(false);
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
                        SetEditStatus();
                    end;
                }
            }
            group("File Attachments")
            {
                Image = Attach;
                action(Attachmentss)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attachments';
                    Image = Attach;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                    end;
                }

            }
        }
    }

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        Message('Function is diabled');
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Selected: Integer;
        Text000: Label 'Choose one of the price approval type:';
        Text001: Label 'Standard,General';
    begin
        Selected := Dialog.StrMenu(Text001, 1, Text000);
        if (Selected = 0) then CurrPage.Close();
        if Selected = 1 then rec.ApprovalType := false else Rec.ApprovalType := true;
        Rec.UserName := Database.UserId();
    end;

    trigger OnAfterGetCurrRecord()
    var
        CustomWflMgmt: Codeunit "Custom Workflow Mgmt";

    begin
        OpenApprovalEntriesExistCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        CanRequestApprovalForRecord := CustomWflMgmt.CanRequestApprovalForRecord(Rec.No_);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        HasApprovalEntries := ApprovalsMgmt.HasApprovalEntries(Rec.RecordId);
        CurrPage.Update();
        SetEditStatus();
        CurrPage.HTMLRender.Page.GetData(Rec.No_, DynamicEditable);
        StatusStyleTxt := CustomWflMgmt.GetStatusStyleText(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        MaterialTreeFunctions: Codeunit "MaterialTreeFunction";
    begin
        MaterialTreeFunctions.DeleteMaterialEntries(-1, Rec.No_);
    end;

    trigger OnClosePage()
    begin
        Rec.SetContent(NewData);
        if Rec.No_ <> '' then begin
            Rec.TestField(Title);
            Rec.TestField("Due Date");
            Rec.TestField(Purpose);
        end;
    end;

    trigger OnOpenPage()
    begin
        SetEditStatus();
        // CurrPage.HTMLRender.Page.GetData(Rec.No_, DynamicEditable);
    end;

    procedure SetEditStatus()
    begin
        CurrPage.Editable(true);
        DynamicEditable := true;
        if (Rec.UserName = UserId) and (p::Open = Rec."Status") then exit;
        DynamicEditable := false;
    end;

    var
        p: enum "Custom Approval Enum";
        OpenApprovalEntriesExistCurrUser, OpenApprovalEntriesExist, CanCancelApprovalForRecord, CanRequestApprovalForRecord
        , HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        DynamicEditable: Boolean;
        StatusStyleTxt: Text;
        EditorReady: Boolean;
        NewData: Text;
        AddNewBtnLbl: Label 'ADD NEW MATERIAL';
        Comment: Text;
        IsHTMLFormatted: Boolean;


}