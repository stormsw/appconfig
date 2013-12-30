Feature: Normalize stages
  In order to compare config versions we need to see un-optimized wizard sections
  it means each transaction for each stage and "all" generalizer converted to real transactions.
  The 'all' keyword may appear in the stage name or transaction code. Unfortunately it can't be
  clear what the real stages should be there, cause wf may have different versions with still running transactions.

  Scenario: Split wizard stages for each transaction code
  Wizard stages may be specified as csv list, we need to split it on separate wizard definition
    Given I have "MultiStageSingleTransaction.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="New,Intake,Rejected,LodgmentApplication" assembly="WAssess"  meta="all;BLDT">
						<![CDATA[...]]>
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
					<wizard stages="S1" assembly="WAssess"  meta="all;T1,T2">
                      <![CDATA[...]]>
                    </wizard>
				</Wizards>
			</configuration>
			"""
    When I normalize "SingleStageMultiTransaction.config"
    Then "SingleStageMultiTransaction.config.xml" produced in data:
    And "SingleStageMultiTransaction.config.xml" contains 2 wizards with transaction in "T1,T2"


  Scenario: Skip wizard with processed stage for given transaction code
  Wizards for same transaction may have several records with same stage, only 1st should be used
  During normalization sort order applied STAGE->TRANSACTION
    Given I have "DupStagesSingleTransaction.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="Stage1" assembly="WAssess"  meta="all;A">
					  <![CDATA[ ... ]]>
					</wizard>
					<wizard stages="Stage2" assembly="WAssess"  meta="all;A">
					  <![CDATA[ ... ]]>
					</wizard>
					<wizard stages="Stage1,Stage2" assembly="WAssess"  meta="all;A,B">
						<![CDATA[ ... ]]>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I normalize "DupStagesSingleTransaction.config"
    Then "DupStagesSingleTransaction.config.xml" produced in data:
    And "DupStagesSingleTransaction.config.xml" contains 4 wizards with stage order "Stage1,Stage1,Stage2,Stage2" and code order "A,B,A,B"

  Scenario: Skip wizard with processed stage for ALL transaction meta code
  Wizards for same transaction may have several records with same stage, only 1st should be used
  Stage appeared to be matched if it contains "all" or transaction code
    Given I have "DupAllStageSingleTransaction.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="Stage1" assembly="WAssess"  meta="all;all">
						<![CDATA[...]]>
					</wizard>
					<wizard stages="Stage1,Stage2" assembly="WAssess"  meta="all;T1">
						<![CDATA[...]]>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I normalize "DupAllStageSingleTransaction.config"
    Then "DupAllStageSingleTransaction.config.xml" produced in data:
    And "DupAllStageSingleTransaction.config.xml" contains 2 wizards with transaction in "T1,all"

  Scenario: Skip wizard with meta-type dependent ALL transaction meta
  Wizards for same transaction may have several records with same stage, but different transaction meta specified
  Stage appeared to be matched if it contains "all" for transaction code but meta should be equal to transaction meta or all
  So normalization and sorting will put such definition just before "Stage-all;all" tag as "stage-<code>;all"

    Given I have "SpecialMetaAllStageSingleTransaction.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="S1" assembly="WAssess"  meta="1;all">
						<![CDATA[...]]>
					</wizard>
					<wizard stages="S1,S2" assembly="WAssess"  meta="all;T1">
						<![CDATA[...]]>
					</wizard>
				</Wizards>
			</configuration>
			"""
    When I normalize "SpecialMetaAllStageSingleTransaction.config"
    Then "SpecialMetaAllStageSingleTransaction.config.xml" produced in data:
    And "SpecialMetaAllStageSingleTransaction.config.xml" contains 3 wizards with stage order "S1,S1,S2" and code order "T1,all,T1"

	Scenario: Sorting of wizards by stages and transaction codes
    Given I have "NormalizeAndSort.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="A,D" assembly="WAssess"  meta="all;T1,T3">
						<![CDATA[...]]>
					</wizard>
					<wizard stages="B,C" assembly="WAssess"  meta="all;T4,T2">
						<![CDATA[...]]>
					</wizard>
				</Wizards>
			</configuration>
	"""
	When I normalize with sorting "NormalizeAndSort.config"
    Then "NormalizeAndSort.config.xml" produced in data:
    And "NormalizeAndSort.config.xml" contains 8 wizards with stage order "A,A,B,B,C,C,D,D" and code order "T1,T3,T2,T4,T2,T4,T1,T3"
