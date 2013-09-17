Feature: Optimize stages
  In order to compress config file we may need to generate optimized wizard sections
  it means each transaction for each stages with same editors set should be placed in same wizard
  But wizard order should matter

  Scenario: Merge wizard stages for each transaction code
  Wizards with same transaction code but different stages having equivalent set of editors should be merged into single wizard description
  Having stages specified as csv

    Given I have "OptSingleStageSingleTransaction.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="New" assembly="WAssess"  meta="all;BLDT">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
					<wizard stages="Intake" assembly="WAssess"  meta="all;BLDT">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I optimize "OptSingleStageSingleTransaction.config"
    Then "OptSingleStageSingleTransaction.config.xml" produced in data:
    And "OptSingleStageSingleTransaction.config.xml" contains 1 wizards with stages="New,Intake" and meta="all;BLDT"

