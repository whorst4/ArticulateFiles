({
	queryItems : function(component, helper) {
        console.log("loading items");
		var action = component.get("c.addProducts");
        action.setParams({
            "orderId": component.get("v.orderId")
        });
        action.setCallback(this, function(response) {
        
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Successfully loaded item");
                component.set("v.OrderProductId", response.getReturnValue());
                component.set("v.loadingItems", false);
            }
            else if (state === "ERROR") {
                helper.handleErrors(response.getError());
            }
            
       	});
        $A.enqueueAction(action);
	},
    
    handleErrors : function(errors) {
    	//set error toast
        let toastParams = {
            title: "Error",
            message: "Unknown Error",
            type: "error",
            duration: 10000
        };
        //pass error message if it exists
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        //fire toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    
	}
})