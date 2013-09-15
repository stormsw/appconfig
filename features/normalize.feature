Feature: Normalize stages
  In order to compare config versions we may need to see un-optimized wizard sections
  it means each transaction for each stage

  Scenario: Split wizard stages for each transaction code
  Wizard stages may be specified as csv list, we need to split it on separate wizard definition
    Given I have "MultiStageSingleTransaction.config" in data:
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
    When I normalize "MultiStageSingleTransaction.config"
    Then "MultiStageSingleTransaction.config.xml" produced in data:
    And "MultiStageSingleTransaction.config.xml" contains 4 wizards with stage in "New,Intake,Rejected,LodgmentApplication"

  Scenario: Split wizards by each transaction code
  Wizard transactions may be specified as csv list, we need to split it on separate wizard definition
    Given I have "SingleStageMultiTransaction.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="LodgmentApplication" assembly="WAssess"  meta="all;BLDT,BLDJ">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I normalize "SingleStageMultiTransaction.config"
    Then "SingleStageMultiTransaction.config.xml" produced in data:
    And "SingleStageMultiTransaction.config.xml" contains 2 wizards with transaction in "BLDT,BLDJ"


  Scenario: Skip wizard with processed stage for given transaction code
  Wizards for same transaction may have several records with same stage, only 1st should be used
    Given I have "DupStagesSingleTransaction.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="LodgmentApplication" assembly="WAssess"  meta="all;BLDT">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
					<wizard stages="Intake,LodgmentApplication" assembly="WAssess"  meta="all;BLDT,BLDJ">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I normalize "DupStagesSingleTransaction.config"
    Then "DupStagesSingleTransaction.config.xml" produced in data:
    And "DupStagesSingleTransaction.config.xml" contains 4 wizards with transaction in "BLDT,BLDJ"

  Scenario: Skip wizard with processed stage for ALL transaction meta code
  Wizards for same transaction may have several records with same stage, only 1st should be used
  Stage appeared to be matched if it contains "all" or transaction code
    Given I have "DupAllStageSingleTransaction.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="LodgmentApplication" assembly="WAssess"  meta="all;all">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
					<wizard stages="Intake,LodgmentApplication" assembly="WAssess"  meta="all;BLDT">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I normalize "DupAllStageSingleTransaction.config"
    Then "DupAllStageSingleTransaction.config.xml" produced in data:
    And "DupAllStageSingleTransaction.config.xml" contains 2 wizards with transaction in "BLDT,all"

  Scenario: Skip wizard with meta-type dependent ALL transaction meta
  Wizards for same transaction may have several records with same stage, but transaction meta may be specified
  Stage appeared to be matched if it contains "all" for transaction code but meta should be equal to skip
    Given I have "SpecialMetaAllStageSingleTransaction.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="LodgmentApplication" assembly="WAssess"  meta="7;all">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
					<wizard stages="Intake,LodgmentApplication" assembly="WAssess"  meta="all;BLDT">
						<editor name="transaction" type="LRS.Client.Assess.TransactionListPage,WAssess" help="28"/>
						<editor name="applicant" type="LRS.Client.Assess.ApplicantsPage,WAssess" help="191"/>
						<editor name="properties" type="LRS.Client.Assess.PropertiesPage,WAssess" help="136" mainForm="PropertyFormNonMandatoryApproximate" plotForm="PlotFormNonMandatory" unitForm="UnitFormNonMandatory" buildingForm="BuildingFormNonMandatory" />
						<editor name="barcode" type="LRS.Client.Assess.PageBarcode,WAssess" help="165"/>
						<editor name="complete" type="LRS.Core.CompletePage,LRS.Data.Controls" help="30"/>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I normalize "SpecialMetaAllStageSingleTransaction.config"
    Then "SpecialMetaAllStageSingleTransaction.xml" produced in data:
    And "SpecialMetaAllStageSingleTransaction.xml" contains 3 wizards with transaction in "BLDT,all"
