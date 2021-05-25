class Vote {
  final String id;
  final int value;

  Vote(this.id, this.value);

  Map<String, dynamic> toJson() => {
        'image_id': id,
        'value': value,
      };
}
