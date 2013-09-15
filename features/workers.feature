Feature: Workers configuration
  In order to check defined wizards stages
  We need to be able to organize and check workers stages

  Scenario: Workers for wizard stages statistics
  Wizard stages may be specified as csv list, we need to split it
    Given I have "WorkersStagesStat.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
              <Workers>
                  <worker stages="New,Intake,Rejected,ReviewBlockingList,LodgmentApplication,LodgmentBill,GenerateRejectionLetter,RejectRegistration,ScanNotice,ReviewSubmission,DataEntry,PrepareNotice,StartGRDemand,DeliverNoticeInvoice,FinalReview,NotificationSurvey,EstimatePremiumGR,EstimateMarketValue,DLAApproval,ApproveGRentReview,PreparePaymentConvFees,IndicatePaymentConvFees,DeliverOffer,ApproveLease,ReviewLease,ApproveLease,PrintLeaseAgreement,SendDLB,ReceivedSignedAgreement,ReceivePlan,PrepareDeedPlan,PrepareDeedCompleted,PrepareDeedPlanEntebbe,SignDeedPlan,SignDeedPlanEntebbe,ReviewSignedDeedPlan,FinalReview,PrepareTitle,SignSealTitle,DeliveryDocs,DeliveryOfRejection,PrepareStampDuties,PaymentStampDuties"
                      registries="registration" assembly="WAssess" type="LRS.Client.Assess.AssessWorker"/>
                  <worker stages="BarcodePrint,IndexData,WithdrawTrans,ParcelCreation,StoreDocuments,BLFinalReview,CreatePropertyCustomary,PayFee,PropertyFileVerification,CreatePropertyFile,BLReview,QCbySample,FinalQCFraudulent,FinalQCSample,ValueExcess,PrepareLetter,ReviewScreen,PrepareCopy,DeedPlanLetter,AssessDeedPlanFees,DeedDetails,IndexingDLO,ReviewIndexingDLO,FinalReviewDecisionCoR,NoticePeriod,ConductHearing,ReturnFieldLetter,AssignInstrumentNo,UpdateParcelInCadastre,ReviewUpdatedParcel,DeRegInstrTitle"
                      registries="registration" assembly="WAssess" type="LRS.Client.Assess.AssessWorker"/>
                  <worker stages="ScanIncoming,ScanDecisionDLB,ScanReceiptDLB,ScanSurveyPaymentReceipt,ScanSurveyFee,PostponeRegistrationPaymentConveyanceFees,PostponeRegistryPaymentStampDuty,ScanSurveyNotification,ScanCancellationNotice,ScanStampDutiy,ScanPaymentAdvice,ScanIncomingDocs,ScanIncomingDocsSurvey,ScanIncomingDocsStrata,ScanOutgoingCT,ScanConfirmationDocs,ScanPropertyFile,ScanDocs,ScanPaymentDocs,ScanInvestReport,ScanOffer,ScanConvFeesDocs,ScanPaymentStampDuties,ScanSignedAgreement,ScanRegDocs,ScanRejection,ScanDeliveryConf,ScanLocPlan,ScanLayoutPlan,ScanIS,ScanJRJ,ScanOutgoingDocs,ScanMutationApproval"
                      registries="registration" assembly="WAssess" type="LRS.Client.Assess.AssessWorker"/>
                  <worker stages="ReceiptIS,DeliverConductSurvey,RequestLayoutPlan,DeliverRegistrationDocs,QueryLeaseholdOffer,CheckLayoutPlan,IndicateReceiptLayoutPlan,ReceiptISStrata,RequestLocationSurvey,ReceiptLocationPlan,ReviewLocSurvey,IssueIS,DispatchApplicant,ReceiptSurveyData,ReviewJRJ,ReDoSurveyData,PrepareSurveyFee,IndicateSurveyPayment,AssessFees,CreateParcelMC,LinkParcel,ConductSiteInspection,PrepareFormPPA1,Review,ApprovalExtensionLetter,QueryFinalReview,NTCWaiting,QueryInitialReview,ReviewDeedPlanEntebbe,FinalReviewEntebbe,InitialReviewRegistry,QueryInitialReviewRegistry"
                      registries="registration" assembly="WAssess" type="LRS.Client.Assess.AssessWorker"/>
                  <worker stages="PrepareIssueDeedVariation,PostponeRegSigningDLB_ULC,PrepareAMN,CoLRSignDocument,PrepareVO,PostRegAssuranceFee"
                      registries="registration" assembly="WAssess" type="LRS.Client.Assess.AssessWorker"/>
                  <worker stages="ValuationReview,PostponeRegAppFees,ScanAppPaymentDocs,ScanReceiptCO,InitialReview,InitialReviewNewCT,ReviewIndicateDecision,PrepareApprovalLetter,DispatchPostpone,ValidateDecision,NoticePeriodPostponeRegistration,FinalReviewDecision,PrepareInstrTitle,SignTitle,ScanOutDocuments,ReviewCoR,RequestStrataPlan,DataEntryStrata,CheckDeedPlanStrata,AssessFeesStrata,CreateStrataMC,LinkStrata,SendPublishing,IndicatePublishing,ReviewCancelation,ApproveRegCancellation,NoticeCancellation,PostponeRegCancellation,FinalDecisionCancellation,PrepareGenerateNotice,CreatePlotDeedPlanMC"
                      registries="registration" assembly="WAssess" type="LRS.Client.Assess.AssessWorker"/>
                  <worker stages="SortRehabilitateDocuments,PreparePaymentAppFees,AssessmentMarketValueRequiredDecision,PostponeRegConvFees,RequestCondominumPlan,PostponeSurveyPayment,CondominiumsPlanRequiredDecision,PrepareInstrauctionSurvey,IndicatePaymentAppFees,PrepareLeaseAgreement,ReviewLeaseAgreement,PrepareLeaseOfferLetter,ReviewLeaseOfferLetter,ReAssessGroundRent,LodgeApplicationRegistry,IndicateDecisions,IndicateReceiptCO,DeliverRegistrationDocs,ALCPublishingInspection,ReceiptSiteInvestigationReport,ReviewInvestigationReport,DLOValidateDecision,PrepareDeferralLetter,ReviewDLO,DLBDecision,IndicateReceiptDLB,DLODecision,DeliverDLB,DLBValidateDecision,ApproveRegDecision,IndicateApprovalSurvey,ResultsSurveyPreparation,ValidateLeaseholdOffer,GenerateLeaseholdOffer,ValidateFreeholdOffer,GenerateFreeholdOffer,IndicateAcceptance,PrepareLease,ReviewLeasAgr,IndicatePaymentStampDuties,IndicateReceiptSigned,SendDLB4Signing,DLBValidate"
                      registries="registration" assembly="WAssess" type="LRS.Client.Assess.AssessWorker"/>
                  <worker stages="Delivery"
                      registries="registration" assembly="WDelivery" type="LRS.Client.Delivery.DeliveryWorker"/>
              </Workers>
			</configuration>
			"""
    When I check workers in "WorkersStagesStat.config"
#Then "WorkersStagesStat.config.xml" produced in data:
#And "WorkersStagesStat.config.xml" contains 4 wizards with stage in "New,Intake,Rejected,LodgmentApplication"

