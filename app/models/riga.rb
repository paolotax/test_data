class Riga < NSManagedObject
  
  @sortKeys = ['titolo']
  @sortOrders = [true]
  
  @sectionKey = nil
  @searchKey  = 'titolo'

  @attributes = [
    { name: 'remote_id',         type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_appunto_id', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'libro_id',          type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'fattura_id',        type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'quantita',          type: NSInteger16AttributeType, default: 1,   optional: true, transient: false, indexed: false},
    { name: 'titolo',            type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'prezzo_unitario',   type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'prezzo_copertina',  type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'prezzo_consigliato',type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'sconto',            type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'importo',           type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false}
  ]

  @relationships = [
    {:name => 'appunto', :destination => 'Appunto', :inverse => 'righe' },
    {:name => 'libro',   :destination => 'Libro',   :inverse => 'libro_righe' }
  ]


end