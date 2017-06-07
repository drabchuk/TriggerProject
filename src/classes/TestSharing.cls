/**
 * Created by new on 02.06.2017.
 */

public with sharing class TestSharing {

    public static void share() {

        User sm15 = [SELECT Id, LastName FROM User WHERE Email = 'sm1517@mail.ru' LIMIT 1];
        Account testShareAccount = [SELECT Id, Name FROM Account WHERE Name = 'Share Test' LIMIT 1];
        System.debug(sm15);
        System.debug(testShareAccount);
        AccountShare shareTestShare = new AccountShare(
                AccountId = testShareAccount.Id,
                UserOrGroupId = sm15.Id,
                AccountAccessLevel = 'read',
                ContactAccessLevel = 'read',
                CaseAccessLevel = 'read',
                OpportunityAccessLevel = 'read'
        );

        insert shareTestShare;

    }

    public static void unshare() {

        User sm15 = [SELECT Id, LastName FROM User WHERE Email = 'sm1517@mail.ru' LIMIT 1];
        Account testShareAccount = [SELECT Id, Name FROM Account WHERE Name = 'Share Test' LIMIT 1];
        System.debug(sm15);
        System.debug(testShareAccount);
        AccountShare shareTestShare = [SELECT Id FROM AccountShare WHERE AccountId = :testShareAccount.Id AND UserOrGroupId = :sm15.Id AND RowCause = 'Manual' LIMIT 1];
        System.debug(shareTestShare);
        delete shareTestShare;

    }


}