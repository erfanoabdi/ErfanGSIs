.class public abstract Lcom/android/server/lights/Light;
.super Ljava/lang/Object;
.source "Light.java"


# static fields
.field public static final BRIGHTNESS_MODE_LOW_PERSISTENCE:I = 0x2

.field public static final BRIGHTNESS_MODE_SENSOR:I = 0x1

.field public static final BRIGHTNESS_MODE_USER:I = 0x0

.field public static final LIGHT_FLASH_HARDWARE:I = 0x2

.field public static final LIGHT_FLASH_NONE:I = 0x0

.field public static final LIGHT_FLASH_TIMED:I = 0x1


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 22
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public abstract pulse()V
.end method

.method public abstract pulse(II)V
.end method

.method public abstract setBrightness(I)V
.end method

.method public abstract setBrightness(II)V
.end method

.method public abstract setColor(I)V
.end method

.method public abstract setFlashing(IIII)V
.end method

.method public abstract setVrMode(Z)V
.end method

.method public abstract turnOff()V
.end method
