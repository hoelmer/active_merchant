require File.dirname(__FILE__) + '/../../../test_helper'

class QuickpayHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = Quickpay::Helper.new('order-500','24352435', :amount => 500, :currency => 'USD')
    @helper.md5secret "mysecretmd5string"
    @helper.return_url 'http://example.com/ok'
    @helper.cancel_return_url 'http://example.com/cancel'
    @helper.notify_url 'http://example.com/notify'
  end
 
  def test_basic_helper_fields
    assert_field 'merchant', '24352435'
    assert_field 'amount', '500'
    assert_field 'ordernumber', 'order-500'
  end
  
  def test_generate_md5string
    assert_equal '3authorize24352435daorder-500500USDhttp://example.com/okhttp://example.com/cancelhttp://example.com/notify00mysecretmd5string', 
                 @helper.generate_md5string
  end
  
  def test_generate_md5check
    assert_equal 'd8f46a7bba02766986f679edfd8465e0', @helper.generate_md5check
  end
  
  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser', :email => 'cody@example.com'
    assert_field '', 'Cody'
    assert_field '', 'Fauser'
    assert_field '', 'cody@example.com'
  end

  def test_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => '',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'
   
    assert_field '', '1 My Street'
    assert_field '', 'Leeds'
    assert_field '', 'Yorkshire'
    assert_field '', 'LS2 7EE'
  end
  
  def test_unknown_address_mapping
    @helper.billing_address :farm => 'CA'
    assert_equal 3, @helper.fields.size
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end
  
  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
end
