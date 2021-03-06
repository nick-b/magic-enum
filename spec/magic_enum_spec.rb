require 'rubygems'
Gem.require('active_record')
require File.dirname(__FILE__) + '/../init'

module MagicEnumHelper
  class TestModelBase
    include MagicEnum
    Statuses = { :unknown => 0, :draft => 1, :published => 2 }
   
    def [](attr_name)
      @status
    end
    
    def []=(attr_name, value)
      @status = value
    end
  end
end

context 'Model with magic enum' do
  include MagicEnumHelper
  
  class TestModel1 < MagicEnumHelper::TestModelBase
    define_enum :status
  end
  
  setup do
    @model = TestModel1.new
  end
  
  specify 'should define methods to get and set enum field' do
    TestModel1.should be_method_defined(:status)
    TestModel1.should be_method_defined(:status=)
  end
  
  specify 'should store enum value using [] operation on model' do
    @model.status = :draft
    @model[:status].should == 1
    @model.status.should == :draft
    @model.status = :unknown
    @model[:status].should == 0
    @model.status.should == :unknown
  end
  
  specify 'should not define simple accessors by default' do
    @model.methods.should_not include('unknown?')
    @model.methods.should_not include('draft?')
    @model.methods.should_not include('published?')
  end
  
  specify 'should not raise error when invalid value received' do
    lambda { @model.status = :invalid }.should_not raise_error(ArgumentError)
  end
  
  specify 'should use default value 0 when invalid value received or current state invalid' do
    @model[:status] = -1
    @model.status.should == :unknown
    @model.status = :published
    @model.status.should == :published
    @model.status = :invalid
    @model[:status].should == 0
    @model.status.should == :unknown
  end
  
  specify 'should return string value when _name method called' do
    @model.status_name.should == 'unknown'
    @model.status = :published
    @model.status_name.should == 'published'
  end
end

context 'Model with magic enum and default value specified' do
  include MagicEnumHelper
  
  class TestModel2 < MagicEnumHelper::TestModelBase
    define_enum :status, :default => 2
  end
  
  setup do
    @model = TestModel2.new
  end
  
  specify 'should use default value when current state is invalid' do
    @model[:status] = -1
    @model.status.should == :published
  end

  specify 'should use default value when invalid value received' do
    @model.status = :invalid
    @model.status.should == :published
    @model[:status].should == 2
  end
  
  specify 'should not interpret nil in the same way as 0' do
    @model[:status].should be_nil
    @model.status.should == :published
    @model[:status] = 0
    @model.status.should == :unknown
  end
end

context 'Model with magic enum and raise_on_invalid option specified' do
  include MagicEnumHelper
  
  class TestModel3 < MagicEnumHelper::TestModelBase
    define_enum :status, :raise_on_invalid => true
  end
  
  setup do
    @model = TestModel3.new
  end

  specify 'should raise error when invalid value received' do
    lambda { @model.status = :invalid }.should raise_error(ArgumentError)
  end
  
  specify 'should show error description when invalid value received' do
    begin
      @model.status = :invalid
    rescue => e
      e.message.should == 'Invalid value "invalid" for :status attribute of the TestModel3 model'
    end
  end
end


context 'Model with magic enum and simple_accessors option specified' do
  include MagicEnumHelper
  
  class TestModel4 < MagicEnumHelper::TestModelBase
    define_enum :status, :simple_accessors => true
  end

  setup do
    @model = TestModel4.new
  end

  specify 'should define simple accessors by default' do
    @model.methods.should include('unknown?')
    @model.methods.should include('draft?')
    @model.methods.should include('published?')
  end
end

context 'Model with magic enum and enum option specified' do
  include MagicEnumHelper
  
  class TestModel5 < MagicEnumHelper::TestModelBase
    Roles = {
      :user => 'u',
      :admin => 'a'
    }
    define_enum :status, :enum => 'Roles'
  end

  setup do
    @model = TestModel5.new
  end

  specify 'should use custom enum' do
    @model.status = :user
    @model.status.should == :user
    @model[:status].should == 'u'
    @model.status = :admin
    @model.status.should == :admin
    @model[:status].should == 'a'
  end
  
  specify 'should use option with min value as default' do
    @model.status = :invalid
    @model.status.should == :admin
  end
end

context 'ActiveRecord::Base class' do
  specify 'should include MagicEnum module' do
    ActiveRecord::Base.included_modules.should include(MagicEnum)
  end
end