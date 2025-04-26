  }

  if (largeIcon != null) {
    // Fixed for Android 15 compatibility - avoiding ambiguous method call
    // Replace bigLargeIcon(null) with a version that specifies the Bitmap type
    Bitmap nullBitmap = null;
    bigPictureStyle.bigLargeIcon(nullBitmap);
  }
  
  mBuilder.setStyle(bigPictureStyle); 