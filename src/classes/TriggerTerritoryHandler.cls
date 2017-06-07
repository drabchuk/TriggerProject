/**
 * Created by Denys on 06.06.2017.
 * This class bounded to TerritoryTrigger class
 * and incapsulates it's functionality.
 */

public with sharing class TriggerTerritoryHandler {

    /**
    * This method chacks each territory in list @param territories
    * and add an error to record if new territory has same name as
    * existing territory within childs of same parent.
     */
    public static void checkUnicness(List<Territory__c> territories) {

        //select roots of new territories to retrieve childs from database
        Map<Id, Set<Territory__c>> newTerritoryMap = groupByParentIds(territories);
        Set<Id> parentsIds = newTerritoryMap.keySet();

        //select all territories that should be validate
        List<Territory__c> existingTerritories = selectTerritoriesByParent(parentsIds);
        if(existingTerritories == null || existingTerritories.isEmpty()) return;

        //construct map of existed territories
        Map<Id, Set<Territory__c>> existingTerritoriesMap = groupByParentIds(existingTerritories);

        //check unicness for each new territory
        Set<Territory__c> newTerritoriesOfParent;
        Set<Territory__c> existingTerritoriesOfParent;

        for (Id parentId : parentsIds) {
            System.assert(
                    existingTerritoriesMap.containsKey(parentId),
                            ExceptionsMessages.INSERTION_PROGRRAM_LOGIC_FAILED_MSG);

            newTerritoriesOfParent = newTerritoryMap.get(parentId);
            existingTerritoriesOfParent = existingTerritoriesMap.get(parentId);

            //check childs unicness of one parent
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
                        //remove it from set
                        newTerritoriesOfParent.remove(newTerritory);
                    }
                }

            }

        }

    }

    public static void relinkTerritoriesAndTerrUsersWhenDelete(Map<Id, Territory__c> territoriesToDelete) {

        Map<Id, Id> newParentsMap = new Map<Id, Id>();
        Map<Id, List<Id>> newTerrUsersMap = new Map<Id, List<Id>>();

        List<Territory__c> allChilds = selectTerritoriesByParent(territoriesToDelete.keySet());

        /*for (Territory__c t : territoriesToDelete) {
            Set<Terr_Urer__c> terrUrers = terrUrerMap.get(t.Id);

        }*/

        List<Terr_Urer__c> allTerrUrers = selectTerrUrers(territoriesToDelete.keySet());

        Map<Id, Set<Terr_Urer__c>> terrUrerMap = groupByTerritories(allTerrUrers);

        allChilds = removeByIds(allChilds, territoriesToDelete.keySet());

        List<Terr_Urer__c> newTerrUrers = new List<Terr_Urer__c>();

        for (Territory__c child : allChilds) {
            Id newParentId = child.Parent_Territory__c;
            while (territoriesToDelete.containsKey(newParentId)) {
                Territory__c parent = territoriesToDelete.get(newParentId);
                newParentId = parent.Parent_Territory__c;

                //relink terr users of rerritory wich is to delete
                Set<Terr_Urer__c> terrUrersOfTerritory = terrUrerMap.get(parent.Id);
                for (Terr_Urer__c tu : terrUrersOfTerritory) {
                    Terr_Urer__c newTU = new Terr_Urer__c(User__c = tu.User__c, Territory__c = child.Id);
                    newTerrUrers.add(newTU);
                }
            }
            newParentsMap.put(child.Id, newParentId);
        }

        System.debug(newTerrUrers);

        delete allTerrUrers;

        insert newTerrUrers;


    }



    private static List<Territory__c> removeByIds(List<Territory__c> territories, Set<Id> idsToDelete) {
        List<Territory__c> res = new List<Territory__c>();
        for (Territory__c t : territories) {
            if (!idsToDelete.contains(t.Id)) {
                res.add(t);
            }
        }
        return res;
    }


    private static Set<Id> retrieveTerritoriesIds(List<Territory__c> territories) {
        Set<Id> ids = new Set<Id>();
        for (Territory__c t : territories) {
            ids.add(t.Id);
        }
        return ids;
    }

    private static List<Territory__c> selectTerritoriesByParent(Set<Id> ids) {
        return
        [
                SELECT Id, Name, Parent_Territory__c
                FROM Territory__c
                WHERE Parent_Territory__c IN :ids
        ];
    }

    private static List<Terr_Urer__c> selectTerrUrers(Set<Id> ids) {
        return
        [
                SELECT Id
                FROM Terr_Urer__c
                WHERE Territory__c IN :ids
        ];
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

    private static Map<Id, Set<Terr_Urer__c>> groupByTerritories(List<Terr_Urer__c> terrUrers) {

        Set<Terr_Urer__c> terrUrersTemp;
        Map<Id, Set<Terr_Urer__c>> territoryMap = new Map<Id, Set<Terr_Urer__c>>();

        for (Terr_Urer__c tu : terrUrers) {

            Id teritoryId = tu.Territory__c;
            if (territoryMap.containsKey(teritoryId)) {
                territoryMap.get(teritoryId).add(tu);
            } else {
                terrUrersTemp = new Set<Terr_Urer__c>();
                terrUrersTemp.add(tu);
                territoryMap.put(teritoryId, terrUrersTemp);
            }

        }

        return territoryMap;

    }

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

}