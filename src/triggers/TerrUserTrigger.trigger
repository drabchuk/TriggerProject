trigger TerrUserTrigger on Terr_Urer__c (before delete, before update, after insert, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            TriggerTerrUserHandler.deleteSharing(Trigger.old);
        } else if (Trigger.isUpdate) {
            TriggerTerrUserHandler.deleteSharing(Trigger.old);
        }
    } else {
        if (Trigger.isInsert) {
            TriggerTerrUserHandler.shareAccountsAndContacts(Trigger.new);
        } else if (Trigger.isUpdate) {
            TriggerTerrUserHandler.shareAccountsAndContacts(Trigger.new);
        }
    }

}