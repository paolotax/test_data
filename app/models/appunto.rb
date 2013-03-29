class Appunto < NSManagedObject

  @sortKeys = ['created_at']
  @sortOrders = [false]
  
  @sectionKey = nil
  @searchKey  = ["cliente_nome", "destinatario", "note", "cliente.comune", "cliente.frazione"]

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

  def self.filtra_status(status)
  
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:Store.shared.context)

    predicates = []
    predicates.addObject(NSPredicate.predicateWithFormat("status contains[cd] %@", argumentArray:[status]))
    request.predicate = NSCompoundPredicate.orPredicateWithSubpredicates(predicates)

    request.sortDescriptors = ["updated_at"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:false)
    }

    error_ptr = Pointer.new(:object)
    data = Store.shared.context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def self.nel_baule
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("cliente.nel_baule = 1"))
    predicates.addObject(NSPredicate.predicateWithFormat("status != 'completato'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    request.sortDescriptors = ["cliente.provincia", "cliente.comune", "cliente.nome"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end




end
