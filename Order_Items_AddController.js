({
	loadData : function(component, event, helper) {
        helper.queryItems(component);
        component.set("v.AddPCItem", false);
	},
    
    handleLoad: function(component, event, helper) {
        console.log('Form Loaded');
    },
    
    handleSubmit: function(component, event, helper) {
        console.log('Form Submitted');
    },
    
    handleSuccess: function(component, event) {
        
        var addPCItem = component.get("v.AddPCItem");
        component.set("v.loadingItems", true);
        var action = component.get("c.UpdateItems");
        action.setParams({
            "orderId" : component.get("v.orderId"),
            "orderItemId" : component.get("v.OrderProductId"),
            "addPC" : addPCItem
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Successfully loaded item");
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.orderId")
                });
                navEvt.fire();
            }
            else if (state === "ERROR") {
                helper.handleErrors(response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },

    handleCancel: function(component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Order"
        });
        homeEvent.fire();
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Order'
        });
        urlEvent.fire();*/
        
    }
})