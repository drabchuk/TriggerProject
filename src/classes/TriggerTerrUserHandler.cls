public with sharing class TriggerTerrUserHandler {

    public static void shareAccountsAndContacts(List<Terr_Urer__c> allTerrUrers) {

        Map<Id, List<Terr_Urer__c>> userTerrMap = groupByUser(allTerrUrers);
        Set<Id> usersIds = userTerrMap.keySet();

        System.debug('user id :' + usersIds);

        for (Id userId : usersIds) {
            List<Terr_Urer__c> terrUrers = userTerrMap.get(userId);

            Set<Id> insertedTerrIds = retrieveTerritoriesIds(terrUrers);

            System.debug('terr ids: ' + insertedTerrIds);

            Set<Id> visibleTerrs = new Set<Id>();
            visibleTerrs.addAll(insertedTerrIds);

            Set<Id> terrIdsToDelete = new Set<Id>();

            Set<Id> currentLayerIds = insertedTerrIds.clone();
            List<Territory__c> layer;

            do  {

                layer = selectTerritoriesByParent(currentLayerIds);
                System.debug('terr layer : ' + layer);
                Set<Id> layerTerrIds = retrieveTerritoriesIds(layer);
                terrIdsToDelete.addAll(layerTerrIds);
                visibleTerrs.addAll(layerTerrIds);
                currentLayerIds = layerTerrIds;

            } while ((layer != null && !layer.isEmpty()));

            System.debug('after bfs');
            System.debug('visible territories : ' + visibleTerrs);
            System.debug('to delete : ' + terrIdsToDelete);

            List<Terr_Urer__c> terrUrersToDelete = selectTerrUrers(terrIdsToDelete);

            System.debug('ter users to delete : ' + terrUrersToDelete);

            delete terrUrersToDelete;

            List<Account> accounts = selectAccountByTerritory(visibleTerrs);

            System.debug('accounts to share : ' + accounts);

            shareOnAccounts(accounts, userId);

        }

    }

    public static void deleteSharing(List<Terr_Urer__c> allTerrUrers) {
        System.debug('all terrs to delete ' + allTerrUrers);

        Map<Id, List<Terr_Urer__c>> userTerrMap = groupByUser(allTerrUrers);

        Set<Id> usersIds = userTerrMap.keySet();

        System.debug('user id :' + usersIds);

        for (Id userId : usersIds) {
            List<Terr_Urer__c> terrUrers = userTerrMap.get(userId);

            Set<Id> insertedTerrIds = retrieveTerritoriesIds(terrUrers);

            System.debug('terr ids: ' + insertedTerrIds);

            Set<Id> terrIdsToDelete = new Set<Id>();
            terrIdsToDelete.addAll(insertedTerrIds);

            Set<Id> currentLayerIds = insertedTerrIds.clone();
            List<Territory__c> layer;
            do {

                layer = selectTerritoriesByParent(currentLayerIds);
                System.debug('terr layer : ' + layer);
                Set<Id> layerTerrIds = retrieveTerritoriesIds(layer);
                terrIdsToDelete.addAll(layerTerrIds);
                currentLayerIds = layerTerrIds;

            } while (layer != null && !layer.isEmpty());

            System.debug('after bfs');

            List<Account> accounts = selectAccountByTerritory(terrIdsToDelete);

            System.debug('accounts to unshare : ' + accounts);

            unshareOnAccounts(accounts, userId);

        }
    }

    private static void shareOnAccounts(List<Account> accounts, Id userId) {

        List<AccountShare> accountShares = new List<AccountShare>();
        List<ContactShare> contactShares = new List<ContactShare>();

        for (Account account : accounts) {
            AccountShare shareRule = new AccountShare(
                    AccountId = account.Id,
                    UserOrGroupId = userId,
                    AccountAccessLevel = 'read',
                    ContactAccessLevel = 'read',
                    CaseAccessLevel = 'read',
                    OpportunityAccessLevel = 'read'
            );
            accountShares.add(shareRule);
            //add sharings to contacts
            System.debug('contacts' + account.Contacts__r);
            for (Reference__c ref : account.Contacts__r) {
                ContactShare contactShare = new ContactShare(
                        ContactId = ref.Contact__c,
                        UserOrGroupId = userId,
                        ContactAccessLevel = 'read'
                );
                contactShares.add(contactShare);
            }

        }

        insert accountShares;
        insert contactShares;
        System.debug('contacts sahres : ' + contactShares);

    }

    private static void unshareOnAccounts(List<Account> accounts, Id userId) {

        List<AccountShare> accountShares;
        List<ContactShare> contactShares;

        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        for (Account account : accounts) {
            accountIds.add(account.Id);
            for (Reference__c ref : account.Contacts__r) {
                contactIds.add(ref.Contact__c);
            }
        }

        accountShares =
        [
                SELECT Id
                FROM AccountShare
                WHERE UserOrGroupId = :userId AND AccountId IN :accountIds
        ];
        contactShares =
        [
                SELECT Id
                FROM ContactShare
                WHERE UserOrGroupId = :userId AND ContactId IN :contactIds
        ];

        delete accountShares;
        delete contactShares;

    }

    private static Set<Id> retrieveTerritoriesIds(List<Terr_Urer__c> terrUrers) {
        Set<Id> ids = new Set<Id>();
        for (Terr_Urer__c terrUrer : terrUrers) {
            ids.add(terrUrer.Territory__c);
        }
        return ids;
    }

    private static Set<Id> retrieveTerritoriesIds(List<Territory__c> territories) {
        Set<Id> ids = new Set<Id>();
        for (Territory__c t : territories) {
            ids.add(t.Id);
        }
        return ids;
    }

    private static Map<Id, List<Terr_Urer__c>> groupByUser(List<Terr_Urer__c> terrUrers) {

        Map<Id, List<Terr_Urer__c>> userMap = new Map<Id, List<Terr_Urer__c>>();

        for (Terr_Urer__c terrUrer : terrUrers) {
            if (userMap.containsKey(terrUrer.User__c)) {
                userMap.get(terrUrer.User__c).add(terrUrer);
            } else {
                List<Terr_Urer__c> temp = new List<Terr_Urer__c>();
                temp.add(terrUrer);
                userMap.put(terrUrer.User__c, temp);
            }
        }

        return userMap;

    }

    private static List<Account> selectAccountByTerritory(Set<Id> terrIds) {

        return
        [
                SELECT
                        Account.Id, Account.Name,
                (SELECT
                        Reference__c.Id,
                        Reference__c.Contact__r.Id,
                        Reference__c.Contact__r.Name
                FROM Account.Contacts__r)
                FROM Account
                WHERE Territory__c IN :terrIds
        ];

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

    private static List<Territory__c> selectSubTree(Set<Id> ids) {

        List<Territory__c> layer;
        do  {

            layer = selectTerritoriesByParent(currentLayerIds);
            System.debug('terr layer : ' + layer);
            Set<Id> layerTerrIds = retrieveTerritoriesIds(layer);
            terrIdsToDelete.addAll(layerTerrIds);
            visibleTerrs.addAll(layerTerrIds);
            currentLayerIds = layerTerrIds;

        } while ((layer != null && !layer.isEmpty()));

    }

}