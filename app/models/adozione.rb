class Adozione < NSManagedObject
  
  PROPERTIES = [:remote_id, :remote_libro_id, :sigla, :remote_classe_id]
  
  @sortKeys = ['remote_classe_id']
  @sectionKey = nil
  @searchKey  = nil

  @attributes = [
    { name: 'remote_id',        type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_classe_id', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_libro_id',  type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'sigla',            type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false}
  ]

  @relationships = [
    { name: 'classe', destination: 'Classe', inverse: 'adozioni' },
    { name: 'libro',  destination: 'Libro',  inverse: 'libro_adozioni' }
  ]


end

