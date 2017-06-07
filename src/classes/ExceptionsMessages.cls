/**
 * Created by new on 06.06.2017.
 */

public abstract with sharing class ExceptionsMessages {

    public static final String INSERTION_PROGRRAM_LOGIC_FAILED_MSG =
            'Exception was occured when inserting new territories. ' +
                    'Check TerritoriesTrigger or TriggerTerriroryHandler  program logic.';

    public static final String INSERTION_WITH_SAME_EXISTING_TERRITORY_NAME_MSG =
            'Attempt to insert territory with same name with existed';

    public static final String INSERTION_WITH_SAME_TERRITORY_NAME_MSG =
            'Attempt to insert territory with same name with another territory to insert';

}