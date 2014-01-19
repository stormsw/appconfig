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
	#note: Intake,New - > cause alphabetical order used
    And "OptSingleStageSingleTransaction.config.xml" contains 1 wizards with stages="Intake,New" and meta="all;BLDT"

  Scenario: Dont Merge wizard stages for each transaction where stage has different Transaction Meta Type
  Wizards with same stages but having different meta-type code can't be merged into single wizard description
  Make sure sorting will put meta with numeric code above metaType 'all' for same stage

    Given I have "OptMultiStageMultiTransactionDiffCode.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="Stage1" assembly="WAssess"  meta="all;T1">
						<editor name="transaction"/>
					</wizard>
					<wizard stages="Stage2" assembly="WAssess"  meta="2;T2">
						<editor name="transaction"/>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I optimize "OptMultiStageMultiTransactionDiffCode.config"
    Then "OptMultiStageMultiTransactionDiffCode.config.xml" produced in data:
    And "OptMultiStageMultiTransactionDiffCode.config.xml" contains 2 wizards with stage order "Stage1,Stage2" and code order "T1,T2"

  Scenario: Merge wizard stages for each transaction code but care out Transaction Meta Type
  Wizards with same editors and different stages, having different meta-type code, but same Transaction CODE must be merged into single wizard description
  Make sure sorting will put meta with numeric code above metaType 'all' for same stage

    Given I have "OptMultiStageSingleTransactionDiffCode.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="Stage1" assembly="WAssess"  meta="all;T1">
						<editor name="transaction"/>
					</wizard>
					<wizard stages="Stage2" assembly="WAssess"  meta="2;T1">
						<editor name="transaction"/>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I optimize "OptMultiStageSingleTransactionDiffCode.config"
    Then "OptMultiStageSingleTransactionDiffCode.config.xml" produced in data:
    And "OptMultiStageSingleTransactionDiffCode.config.xml" contains 1 wizards with stages="Stage1,Stage2" and meta="all;T1"

  Scenario: Optimizer should always rewrite transaction codes in meta to alphabetic order
    Its hard to compare result over false differences occured after optmization
    Given I have "OptSingleStageMultiTransactionMixCode.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="Stage1" assembly="WAssess"  meta="all;T3,T1,T2">
						<editor name="transaction"/>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I optimize "OptSingleStageMultiTransactionMixCode.config"
    Then "OptSingleStageMultiTransactionMixCode.config.xml" produced in data:
    And "OptSingleStageMultiTransactionMixCode.config.xml" contains 1 wizards with stages="Stage1" and meta="all;T1,T2,T3"
