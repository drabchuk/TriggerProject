/**
 * Created by new on 06.06.2017.
 */

public with sharing class TriggerTerritoryHandler {

    public static Boolean checkUnicness(Territory__c territory) {

        Id parentTerritoryId = territory.Parent_Territory__c;

        List<Territory__c> neighbours =
        [
                SELECT Id, Name
                FROM Territory__c
                WHERE Parent_Territory__c = :parentTerritoryId
        ];

        for (Territory__c t : neighbours) {
            if (t.Name == territory.Name) {
                return false;
            }
        }

        return true;

    }

    public static void checkUnicness(List<Territory__c> territories) {

        //select roots of new territories to retrieve childs from database
        List<Territory__c> newTerritories;//temp
        Map<Id, Set<Territory__c>> newTerritoryMap = groupByParentIds(territories);

        //select all territories that should be validate
        List<Territory__c> existingTerritories =
        [
                SELECT Id, Name, Parent_Territory__c
                FROM Territory__c
                WHERE Parent_Territory__c IN :newTerritoryMap.keySet()
        ];

        //construct map of existed territories
        Map<Id, Set<Territory__c>> existingTerritoriesMap = groupByParentIds(existingTerritories);

        //check unicness for each new territory
        Set<Id> parentsIds = newTerritoryMap.keySet();
        Set<Territory__c> newTerritoriesOfParent;
        Set<Territory__c> existingTerritoriesOfParent;
        for (Id parentId : parentsIds) {
            System.assert(
                    existingTerritoriesMap.containsKey(parentId),
                            ExceptionsMessages.INSERTION_PROGRRAM_LOGIC_FAILED_MSG);

            newTerritoriesOfParent = newTerritoryMap.get(parentId);
            existingTerritoriesOfParent = existingTerritoriesMap.get(parentId);

            //check unicness of one parent
            for (Territory__c newTerritory : newTerritoriesOfParent) {

                //check with new territories
                for (Territory__c newTerritoryToCheck : newTerritoriesOfParent) {
                    if (newTerritory != newTerritoryToCheck) {
                        if (newTerritory.Name == newTerritoryToCheck.Name) {
                            newTerritory.addError(ExceptionsMessages.INSERTION_WITH_SAME_TERRITORY_NAME_MSG);
                            newTerritoryToCheck.addError(ExceptionsMessages.INSERTION_WITH_SAME_TERRITORY_NAME_MSG);
                            //remove them from set
                            newTerritoriesOfParent.remove(newTerritory);
                            newTerritoriesOfParent.remove(newTerritoryToCheck);
                        }
                    }
                }

                //check with existing territories
                for (Territory__c existingTerritory : existingTerritoriesOfParent) {
                    if (newTerritory.Name == existingTerritory.Name) {
                        newTerritory.addError(ExceptionsMessages.INSERTION_WITH_SAME_EXISTING_TERRITORY_NAME_MSG);
                        //remove them from set
                        newTerritoriesOfParent.remove(newTerritory);
                    }
                }

            }

        }

    }

    private static Map<Id, Set<Territory__c>> groupByParentIds(List<Territory__c> territories) {

        Set<Territory__c> territoriesTemp;
        Map<Id, Set<Territory__c>> territoryMap = new Map<Id, Set<Territory__c>>();

        for (Territory__c t : territories) {

            Id parentId = t.Parent_Territory__c;
            if (territoryMap.containsKey(parentId)) {
                territoryMap.get(parentId).add(t);
            } else {
                territoriesTemp = new Set<Territory__c>();
                territoriesTemp.add(t);
                territoryMap.put(parentId, territoriesTemp);
            }

        }

        return territoryMap;

    }

}