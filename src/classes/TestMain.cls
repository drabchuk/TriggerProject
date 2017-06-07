/**
 * Created by new on 06.06.2017.
 */

public with sharing class TestMain {
    
    public static void attemptToShareContact() {
        User u = [SELECT Id FROM User WHERE Email = 'sm1517@mail.ru'];
        Contact c = [SELECT Id FROM Contact WHERE LastName = 'Mc Donald'];
        ContactShare share = new ContactShare(
        	UserOrGroupId = u.Id,
            ContactId = c.Id,
            ContactAccessLevel = 'Read',
            RowCause = 'Manual'
        );
        List<ContactShare> shares = new List<ContactShare>();
        shares.add(share);
        insert shares;
    }
    
    public static void checkSharing() {
        User u = [SELECT Id FROM User WHERE Email = 'sm1517@mail.ru'];
        Contact c = [SELECT Id FROM Contact WHERE LastName = 'Mc Donald'];
        List<ContactShare> shares = 
        [
            SELECT Id, UserOrGroupId, ContactId, ContactAccessLevel
        	FROM ContactShare
        	WHERE UserOrGroupId = :u.Id AND ContactId = :c.Id
        ];
    }

    public static void selectAccountsAndContacts() {
        Set<Id> ids = new Set<Id>();
        Territory__c ukraine = [SELECT Id FROM Territory__c WHERE Name = 'Ukraine'];
        ids.add(ukraine.id);
        List<Account> accounts = TriggerTerrUserHandler.selectAccountByTerritory(ids);

        System.debug(accounts[0].Contacts__r[1].Contact__r.Name);

    }

    public static void unicRun() {
        Territory__c ukraine = [SELECT Id, Name, Parent_Territory__c FROM Territory__c WHERE Name = 'Ukraine' LIMIT 1];
        Territory__c world = [SELECT Id, Name, Parent_Territory__c FROM Territory__c WHERE Name = 'World' LIMIT 1];
        System.debug(world);
        Territory__c dniproState = new Territory__c(Name = 'Dnipro State', Parent_Territory__c = ukraine.Id);
        Territory__c borschaga1 = new Territory__c(Name = 'borschaga', Parent_Territory__c = ukraine.Id);
        Territory__c borschaga2 = new Territory__c(Name = 'borschaga', Parent_Territory__c = ukraine.Id);
        Territory__c poland = new Territory__c(Name = 'Poland', Parent_Territory__c = world.Id);
        List<Territory__c> territories = new List<Territory__c>();
        territories.add(dniproState);
        territories.add(poland);
        territories.add(borschaga1);
        territories.add(borschaga2);
        insert territories;
    }

    public static void mapChecking() {
        Map<Id, List<Territory__c>> territoryMap = new Map<Id, List<Territory__c>>();
        System.debug(territoryMap.containsKey(null));
        territoryMap.put(null, new List<Territory__c>());
        System.debug(territoryMap.containsKey(null));
        List<Territory__c> terrs = territoryMap.get(null);
        System.debug(terrs);
    }

}