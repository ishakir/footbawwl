ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  self.use_instantiated_fixtures = true

  # Add more helper methods to be used by all tests here...
  def get_assigns(action, variable, params = nil) 
    get action, params
    return assigns(variable)
  end
  
  def assert_assigns_not_nil(action, variable, params = nil, message = nil)
    get action, params
    assert_not_nil assigns(variable), message
  end
  
  def can_view_action(action, params=nil)
    get action, params
    assert_response :success 
  end
  
  def can_view_template(action, params=nil)
    get action, params
    assert_template action
  end
  
  def can_view_layout(action, layout, params=nil)
    get action, params
    assert_template layout: layout
  end
  
  def can_create_entity_obj(expected_response, action, params, ent_name)
    post action, params
    assert_response(expected_response, "Failed to create " + ent_name)
  end
    
  def can_get_entity_list(action, ent_obj, obj_name)
    entity_obj = get_assigns(action, ent_obj)
    assert entity_obj.length > 1, "One or less " + obj_name + " were listed"
  end
  
  def can_get_entity_row_name(action, params, ent_obj, obj_name)
    row_obj = get_assigns(action, ent_obj, params)    
    assert_equal row_obj.name, obj_name, "Failed to show " + obj_name
  end
  
  def can_see_entity_obj_not_nil(action, ent_obj, obj_name)
    assert_not_nil get_assigns(action,ent_obj), obj_name + " object from view page is nil"
  end
  
  def can_see_entity_obj_num_is(action, ent_obj, num, obj_name)
    obj = get_assigns(action, ent_obj)
    assert_equal obj.length, num, "Incorrect number of " + obj_name + " objects shown"
  end
  
  def can_see_entity_row_index_eq(action, ent_obj, i, exp_row_name, obj_name)
    assert_equal get_assigns(action, ent_obj)[i].name, exp_row_name, "#{i} " + obj_name + " object entry on view page is not" + exp_row_name
  end
  
  def can_del_ent_obj(action, params)
    post action, params
    assert_raise ActiveRecord::RecordNotFound do
       User.find(params[:id])
     end
  end
  
  def fail_del_ent_obj(actions, param, obj_name)
    post actions, param
    assert_response(:missing, "Managed to delete imaginary " + obj_name)
  end
    
  
  def can_edit_entity_obj_name(action, params, ent_obj, exp_row_name, obj_name)
    pre_edit_obj = ent_obj.find(params[:id])
    post action, params
    row_obj = ent_obj.find(params[:id])
    assert pre_edit_obj.name != row_obj.name, "Failed to update " + obj_name + " " + exp_row_name
  end
  
  def fail_edit_fake_entity_row_obj(action, params, obj_name)
    post action, params
    assert_response(:missing, "Managed to update non-existent " + obj_name)
  end
end