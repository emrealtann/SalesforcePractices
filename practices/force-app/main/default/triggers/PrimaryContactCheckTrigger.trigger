trigger PrimaryContactCheckTrigger on Contact(
    before insert,
    before update,
    after insert,
    after update
) {
    PrimaryContactCheckTriggerHandler handler = new PrimaryContactCheckTriggerHandler();

    if (Trigger.isBefore) {
        handler.OnBefore(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        handler.OnAfterUpdate(Trigger.old, Trigger.new);
    } else if (Trigger.isAfter && Trigger.isInsert) {
        handler.OnAfterInsert(Trigger.new);
    }

}