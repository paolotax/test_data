class Adozione < NSManagedObject
  
  PROPERTIES = [:remote_id, :remote_libro_id, :sigla, :remote_classe_id]
  
  @sortKeys = ['remote_classe_id']
  @sortOrders = [true]
  
  @sectionKey = nil
  @searchKey  = nil

  @attributes = [
    { name: 'remote_id',        type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_classe_id', type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'remote_libro_id',  type: NSInteger32AttributeType, default: nil, optional: true, transient: false, indexed: false},
    { name: 'sigla',            type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'kit_1',            type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'kit_2',            type: NSStringAttributeType,    default: "",  optional: true, transient: false, indexed: false},
    { name: 'created_at',       type: NSDateAttributeType,    default: nil,  optional: true, transient: false, indexed: false},
    { name: 'updated_at',       type: NSDateAttributeType,    default: nil,  optional: true, transient: false, indexed: false}
        
  ]

  @relationships = [
    { name: 'classe', destination: 'Classe', inverse: 'adozioni' },
    { name: 'libro',  destination: 'Libro',  inverse: 'libro_adozioni' }
  ]

  def save_to_backend
    if self.remote_id == 0  
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
end

