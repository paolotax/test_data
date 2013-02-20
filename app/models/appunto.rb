class Appunto < NSManagedObject

  @sortKeys = ['created_at']
  @sectionKey = nil
  @searchKey  = ["cliente_nome", "destinatario", "note"]

  @attributes = [
    { name: 'remote_id',    type: NSInteger32AttributeType, default: nil,   optional: true, transient: false, indexed: false},
    { name: 'ClienteId',    type: NSInteger32AttributeType, default: nil,   optional: true, transient: false, indexed: false},
    { name: 'status',       type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'cliente_nome', type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'destinatario', type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'note',         type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'telefono',     type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'email',        type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'created_at',   type: NSDateAttributeType,    default: nil,  optional: true, transient: false, indexed: false},
    { name: 'updated_at',   type: NSDateAttributeType,    default: nil,  optional: true, transient: false, indexed: false},
    { name: 'totale_copie', type: NSInteger32AttributeType, default: 0,   optional: true, transient: false, indexed: false},
    { name: 'totale_importo', type: NSDecimalAttributeType, default: 0.0, optional: true, transient: false, indexed: false}
  ]

  @relationships = [
    { name: 'cliente', destination: 'Cliente', inverse: 'appunti' },
    { name: 'righe',   destination: 'Riga', inverse: 'appunto', json: 'righe', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule }
  ]

  @sections = [
    [nil, ['Destinatario', 'destinatario', :text, 'Stato', 'status', :text]],
    ['Note', ['Note', 'note', :longtext]]
  ]


end
