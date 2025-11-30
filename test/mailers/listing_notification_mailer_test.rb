require "test_helper"

class ListingNotificationMailerTest < ActionMailer::TestCase
  def setup
    @seller = users(:seller)
    @seller_profile = seller_profiles(:seller_profile)
    @listing = listings(:listing_one)
  end

  test "listing_approved" do
    mail = ListingNotificationMailer.listing_approved(@listing)
    assert_equal "✅ Votre annonce \"#{@listing.title}\" a été approuvée", mail.subject
    assert_equal [@seller.email], mail.to
    assert_equal ["notifications@ideal-reprise.fr"], mail.from
  end

  test "listing_rejected" do
    mail = ListingNotificationMailer.listing_rejected(@listing)
    assert_equal "❌ Votre annonce \"#{@listing.title}\" a été rejetée", mail.subject
    assert_equal [@seller.email], mail.to
    assert_equal ["notifications@ideal-reprise.fr"], mail.from
  end
end
