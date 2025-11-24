require "test_helper"

class ListingNotificationMailerTest < ActionMailer::TestCase
  test "listing_approved" do
    mail = ListingNotificationMailer.listing_approved
    assert_equal "Listing approved", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "listing_rejected" do
    mail = ListingNotificationMailer.listing_rejected
    assert_equal "Listing rejected", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
