
module Caboose

  module AccessControl
    
    def self.included(subject)
      subject.extend(ClassMethods)
      if subject.respond_to? :helper_method
        subject.helper_method(:permit?)
      end
    end
    
    module ClassMethods  
      #  access_control [:create, :edit] => 'admin & !blacklist',
      #                 :update => '(admin | moderator) & !blacklist',
      #                 :list => '(admin | moderator | user) & !blacklist'
      def access_control(actions={})
        # Add class-wide permission callback to before_filter
        defaults = {}  
        if block_given?
          yield defaults 
          default_block_given = true  
        end        
        before_filter do |c|
          c.default_access_context = defaults if default_block_given
          @access = AccessSentry.new(c, actions)
          if @access.allowed?(c.action_name)
             c.send(:permission_granted)  if c.respond_to?(:permission_granted, true)
          else    
            if c.respond_to?(:permission_denied, true)
              c.send(:permission_denied)
            else  
              c.send(:render, :text => "You have insuffient permissions to access #{c.controller_name}/#{c.action_name}")
            end
          end
        end
      end 
    end # ClassMethods 

    # return the active access handler, fallback to RoleHandler
    # implement #retrieve_access_handler to return non-default handler
    def access_handler
      if respond_to?(:retrieve_access_handler, true)
        @handler ||= retrieve_access_handler
      else
        @handler ||= RoleHandler.new
      end
    end

    # the current access context; will be created if not setup
    # will add current_user and merge any other elements of context
    def access_context(context = {})     
      default_access_context.merge(context)
    end

    def default_access_context
      @default_access_context ||= {}
      @default_access_context[:user] = send(:current_user) if respond_to?(:current_user, true)
      @default_access_context 
    end

    def default_access_context=(defaults)
      @default_access_context = defaults      
    end

    def permit?(logicstring, context = {})
      access_handler.process(logicstring.dup, access_context(context))
    end

    class AccessSentry
     
      def initialize(subject, actions={})
        @actions = actions.inject({}) do |auth, current|
          [current.first].flatten.each { |action| auth[action] = current.last }
          auth
        end
        @subject = subject
      end 
     
      def allowed?(action)
        if @actions.has_key? action.to_sym
          if @actions[action.to_sym].nil?         # used for removing DEFAULT behavior
            return true
          else
            return @subject.access_handler.process(@actions[action.to_sym].dup, @subject.access_context)
          end
        elsif @actions.has_key? :DEFAULT
          return @subject.access_handler.process(@actions[:DEFAULT].dup, @subject.access_context) 
        else
          return true
        end  
      end
   
    end # AccessSentry
  
  end # AccessControl  

  module Helpers
    # restrict_to "admin | moderator" do
    #   link_to "foo"
    # end
    def restrict_to(logicstring, context = {}, &block)
      return '' if current_user.nil?
      result = ''
      if permit?(logicstring, context)
        result = capture(&block) if block_given?
      end
      result
    end
  end

end # Caboose    





