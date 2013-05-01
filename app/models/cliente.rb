class Cliente < NSManagedObject
  
  attr_accessor :cliente
  
  @sortKeys   = ['cliente_tipo', 'nome']
  @sortOrders = [false, true]

  @sectionKey = "cliente_tipo"
  @searchKey  = ['nome', 'comune', 'frazione']

  @attributes = [
    { name: 'ClienteId', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'nome',      type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'comune',    type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'frazione',  type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'cliente_tipo', type: NSStringAttributeType, default: '',  optional: true, transient: false, indexed: false},
    { name: 'indirizzo', type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'cap',       type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'provincia', type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'telefono',  type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'email',     type: NSStringAttributeType,    default: '',  optional: true, transient: false, indexed: false},
    { name: 'latitude',  type: NSDoubleAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'longitude', type: NSDoubleAttributeType,   default: 0.0, optional: true, transient: false, indexed: false},
    { name: 'ragione_sociale',  type: NSStringAttributeType, default: '', optional: true, transient: false, indexed: false},
    { name: 'codice_fiscale',   type: NSStringAttributeType, default: '', optional: true, transient: false, indexed: false},
    { name: 'partita_iva',      type: NSStringAttributeType, default: '', optional: true, transient: false, indexed: false},
    { name: 'appunti_da_fare',    type: NSInteger16AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'appunti_in_sospeso', type: NSInteger16AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'nel_baule',          type: NSBooleanAttributeType, default: 0, optional: true, transient: false, indexed: false},
    { name: 'fatto',              type: NSBooleanAttributeType, default: 0, optional: true, transient: false, indexed: false}
  
  ]

  @relationships = [
    { name: 'appunti', destination: 'Appunto', inverse: 'cliente', json: 'appunti', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule },
    { name: 'classi', destination: 'Classe', inverse: 'cliente', json: 'classi', optional: true, transient: false, indexed: false, ordered: true, min: 0, max: NSIntegerMax, del: NSCascadeDeleteRule }
  ]

  def save_to_backend
    if self.ClienteId == 0  
      Store.shared.backend.postObject(self, path:nil, parameters:nil, 
                          success:lambda do |operation, result|
                                    Store.shared.persist
                                  end, 
                          failure:lambda do |operation, error|
                                  end)
    else
      Store.shared.backend.putObject(self, path:nil, parameters:nil, 
                          success:lambda do |operation, result|
                                    Store.shared.persist
                                  end, 
                          failure:lambda do |operation, error|
                                  end)
    end
  end


  def citta
    self.frazione.blank? ? self.comune : self.frazione
  end

  def title
    nome
  end

  def coordinate
    CLLocationCoordinate2D.new(latitude, longitude)
  end

  # def addAppuntiObject(value)
  #   # override default core-data generated accessor, faulty in iOS5.1
  #   # see http://stackoverflow.com/questions/7385439/problems-with-nsorderedset
  #   tempSet = NSMutableOrderedSet.orderedSetWithOrderedSet(self.appunti)
  #   tempSet.addObject(value)
  #   self.appunti = tempSet
  # end  

  def mapItem
    
    # addressDict = {
    #   kABPersonAddressCountryKey: "IT",
    #   kABPersonAddressCityKey: "#{frazione} #{comune}",
    #   kABPersonAddressStreetKey: "#{indirizzo}",
    #   kABPersonAddressZIPKey: "#{cap}"
    # }

    placemark = MKPlacemark.alloc.initWithCoordinate(self.coordinate, addressDictionary:nil)
    mapItem = MKMapItem.alloc.initWithPlacemark(placemark)
    mapItem.name = self.title
    mapItem.phoneNumber = "#{telefono}";
    mapItem.url = NSURL.URLWithString("http://youpropa.com/clienti/#{self.ClienteId}")
    mapItem
  end

  def self.nel_baule
    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName(name, inManagedObjectContext:context)

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("nel_baule = 1"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    request.sortDescriptors = ["provincia", "comune", "nome"].collect { |sortKey|
      NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    }
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data
  end

  def sum_copie

    context = Store.shared.context
    request = NSFetchRequest.alloc.init
    request.entity = NSEntityDescription.entityForName("Cliente", inManagedObjectContext:context)
    request.resultType = NSDictionaryResultType

    pred = nil
    predicates = [] 
    predicates.addObject(NSPredicate.predicateWithFormat("ClienteId = '#{self.ClienteId}'"))
    pred = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
    request.predicate = pred

    keyPathExpression = NSExpression.expressionForKeyPath "appunti" 
    countExpression = NSExpression.expressionForFunction("count:", arguments:NSArray.arrayWithObject(keyPathExpression))


    expressionDescription = NSExpressionDescription.alloc.init
    expressionDescription.setName("sum")
    expressionDescription.setExpression(countExpression)
    expressionDescription.setExpressionResultType(NSInteger32AttributeType)

    request.setPropertiesToFetch NSArray.arrayWithObject(expressionDescription)

    # request.sortDescriptors = ["provincia", "comune", "nome"].collect { |sortKey|
    #   NSSortDescriptor.alloc.initWithKey(sortKey, ascending:true)
    # }
    
    error_ptr = Pointer.new(:object)
    data = context.executeFetchRequest(request, error:error_ptr)
    if data == nil
      raise "Error when fetching data: #{error_ptr[0].description}"
    end
    data

  end

  def nel_baule?
    nel_baule == 1
  end
end