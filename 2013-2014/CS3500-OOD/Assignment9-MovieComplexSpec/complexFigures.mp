input metauml;

beginfig(1);
    Class.User("CustomerView")()();
    Class.Manager("ManagerView")()();
    Class.Accountant("BillingView")()();
    Class.Controller("ComplexController")()();
    Class.Data("Data")()();

    leftToRight(90)(User, Controller, Manager);
    topToBottom(50)(Accountant, Controller, Data);
    drawObjects(User,Manager,Accountant,Controller, Data);

    link(association)(User.e -- Controller.w);
    link(association)(Manager.w -- Controller.e);
    link(associationUni)(Controller.n -- Accountant.s);
    link(association)(Controller.s -- Data.n);

    item.CoUs(iAssoc)("Manages Data")(CoUs.ne = Controller.w);
    item.CoMa(iAssoc)("Manages Data")(CoMa.nw = Controller.e);
    item.CoAc(iAssoc)("Supplies CSV file")(CoAc.sw = Controller.n);
    item(iAssoc)("buys tickets")(obj.sw = User.e);
    item(iAssoc)("manages events/movies")(obj.se = Manager.w);
endfig;

end