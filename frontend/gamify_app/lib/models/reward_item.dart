/// Represents a purchasable item in the rewards shop.
/// Used by ShopScreen and mapped from [RewardDto].
class RewardItem {
  final String id;
  final String title;
  final String description;
  final int price; // cost in coins
  final String? imageUrl;
  final bool available;
  bool purchased;

  RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    this.available = true,
    this.purchased = false,
  });
}
