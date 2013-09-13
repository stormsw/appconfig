Feature: Normalize stages
In order to compare config versions we may need to see un-optimized wizard sections
it means each transaction for each stage

	Scenario: Split wizard stages for each trnsaction code
	Wizard stages may be specified as csv list, we need to split it on separate wizard definition
		Given I have MultiStageSingleTransaction.config in data:
			"""
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="New,Intake,Rejected,LodgmentApplication" assembly="WAssess"  meta="all;BLDT">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
				</Wizards>
			</configuration>
			"""
		When I run normalize
		Then MultiStageSingleTransaction.config.xml produced
		And MultiStageSingleTransaction.config.xml contains 4 wizards:"New,Intake,Rejected,LodgmentApplication"