module Caboose
  
  class AccessHandler   
    include LogicParser

    def check(key, context)
      false
    end
  
  end
   
  class RoleHandler < AccessHandler 
    
    def check(key, context)  
      context[:user].roles.pluck(:title).include? key.downcase
    end
        
  end # End RoleHandler

  # Usage:
  #  def retrieve_access_handler
  #    Caboose::VirtualRoleHandler.new(self)
  #  end
  class VirtualRoleHandler < RoleHandler
    def initialize(controller)
      @controller = controller
    end

    def check(key, context)
      super || (@controller.respond_to?(key.to_sym, true) && @controller.send(key.to_sym))
    end
  end
end
