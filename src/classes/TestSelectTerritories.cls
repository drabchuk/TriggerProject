/**
 * Created by new on 02.06.2017.
 */

public with sharing class TestSelectTerritories {

    public static void run() {
       /* Territory__c world =
        [SELECT
                Parent_Territory__c.Id,
                Parent_Territory__c.Name,
                (SELECT Territory__c.Id, Territory__c.Name FROM Child_Territories__r)
        FROM Territory__c WHERE Name = 'world'];
        System.debug(world);*/
    }

}