class Classe < NSManagedObject
  
  PROPERTIES = [:remote_id, :classe, :sezione, :nr_alunni, :remote_cliente_id, :adozioni]
  
  @sortKeys = ['remote_cliente_id', 'num_classe', 'sezione']
  @sortOrders = [true, true, true]
  
  @sectionKey = nil
  @searchKey  = nil

  @attributes = [
    { name: 'remote_id',         type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_cliente_id', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'num_classe',        type: NSInteger16AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'sezione',           type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'nr_alunni',         type: NSInteger16AttributeType, default: 0,   optional: true, transient: false, indexed: false},
    { name: 'note',              type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false}
  ]

  @relationships = [
    { name: 'cliente',  destination: 'Cliente',  inverse: 'classi' },
    { name: 'adozioni', destination: 'Adozione', inverse: 'classe', json: 'adozioni', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule }
  ]

end