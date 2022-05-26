#bin

echo "Copy one of following commands and execute it in a command terminal"
exit

# harvest automatically
java -jar exotic-standalone/target/exotic-standalone*.jar harvest https://www.amazon.com/Best-Sellers-Automotive/zgbs/automotive/

# harvest automatically with page component specified
java -jar exotic-standalone/target/exotic-standalone*.jar harvest https://www.amazon.com/Best-Sellers-Automotive/zgbs/automotive/ -outLink a[href~=/dp/] -component "#centerCol" -component "#buybox"

# scrape specified fields in a single page
java -jar exotic-standalone/target/exotic-standalone*.jar scrape https://www.amazon.com/dp/B09V3KXJPB -field "#productTitle" -field "#acrPopover" -field "#acrCustomerReviewText" -field "#askATFLink"

# scrape specified fields from out pages
java -jar exotic-standalone/target/exotic-standalone*.jar scrape https://www.amazon.com/Best-Sellers-Automotive/zgbs/automotive/ -outLink a[href~=/dp/] -field "#productTitle" -field "#acrPopover" -field "#acrCustomerReviewText" -field "#askATFLink"
