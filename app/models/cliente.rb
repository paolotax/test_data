class Cliente < NSManagedObject
  
  attr_accessor :cliente
  
  @sortKeys = ['cliente_tipo', 'nome']
  @sectionKey = "cliente_tipo"
  @searchKey  = ['nome', 'comune', 'frazione']

  @attributes = [
    { name: 'ClienteId', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'nome',      type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'comune',    type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'frazione',  type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'cliente_tipo', type: NSStringAttributeType, default: '', optional: true, transient: false, indexed: false},
    { name: 'indirizzo', type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'cap',       type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'provincia', type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'telefono',  type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'email',     type: NSStringAttributeType,    default: '', optional: true, transient: false, indexed: false},
    { name: 'latitude',  type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'longitude', type: NSDecimalAttributeType,   default: 0.0, optional: true, transient: false, indexed: false}
  ]

  @relationships = [
    { name: 'appunti', destination: 'Appunto', inverse: 'cliente', json: 'appunti', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule }
  ]

  def citta
    self.frazione.blank? ? self.comune : self.frazione
  end

  def addAppuntiObject(value)
    # override default core-data generated accessor, faulty in iOS5.1
    # see http://stackoverflow.com/questions/7385439/problems-with-nsorderedset
    tempSet = NSMutableOrderedSet.orderedSetWithOrderedSet(self.appunti)
    tempSet.addObject(value)
    self.appunti = tempSet
  end  



end