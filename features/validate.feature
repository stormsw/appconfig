Feature: Validate config
  In order to find ambigous and wrong config entries we need set of validation rules

	Scenario: Check that section <all, all> must be last for stage
    Given I have "ValidateWizardOverridedByAll.config" in data:
    """
			<?xml version="1.0"?>

			<configuration>
				<Wizards>
					<wizard stages="A" assembly="WAssess"  meta="all;all">
						<editor name="1" type="2" help="28"/>
					</wizard>
					<wizard stages="A" assembly="WAssess"  meta="all;T1">
						<editor name="1" type="2" help="28"/>
						<editor name="2" type="3" help="28"/>
					</wizard>
				</Wizards>
			</configuration>
	"""
	When I validate stages "ValidateWizardOverridedByAll.config"
    Then "ValidateWizardOverridedByAll.config.log" produced in data:
    And "ValidateWizardOverridedByAll.config.log" contains message: [ERROR] - Stage "A" for transaction T1 is hidden by section meta="all;all"
