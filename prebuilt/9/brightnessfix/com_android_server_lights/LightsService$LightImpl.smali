.class final Lcom/android/server/lights/LightsService$LightImpl;
.super Lcom/android/server/lights/Light;
.source "LightsService.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/android/server/lights/LightsService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x12
    name = "LightImpl"
.end annotation


# instance fields
.field private mBrightnessMode:I

.field private mColor:I

.field private mFlashing:Z

.field private mId:I

.field private mInitialized:Z

.field private mLastBrightnessMode:I

.field private mLastColor:I

.field private mMode:I

.field private mOffMS:I

.field private mOnMS:I

.field private mUseLowPersistenceForVR:Z

.field private mVrModeEnabled:Z

.field final synthetic this$0:Lcom/android/server/lights/LightsService;


# direct methods
.method private constructor <init>(Lcom/android/server/lights/LightsService;I)V
    .registers 3
    .param p2, "id"    # I

    .line 37
    iput-object p1, p0, Lcom/android/server/lights/LightsService$LightImpl;->this$0:Lcom/android/server/lights/LightsService;

    invoke-direct {p0}, Lcom/android/server/lights/Light;-><init>()V

    .line 38
    iput p2, p0, Lcom/android/server/lights/LightsService$LightImpl;->mId:I

    .line 39
    return-void
.end method

.method synthetic constructor <init>(Lcom/android/server/lights/LightsService;ILcom/android/server/lights/LightsService$1;)V
    .registers 4
    .param p1, "x0"    # Lcom/android/server/lights/LightsService;
    .param p2, "x1"    # I
    .param p3, "x2"    # Lcom/android/server/lights/LightsService$1;

    .line 35
    invoke-direct {p0, p1, p2}, Lcom/android/server/lights/LightsService$LightImpl;-><init>(Lcom/android/server/lights/LightsService;I)V

    return-void
.end method

.method static synthetic access$300(Lcom/android/server/lights/LightsService$LightImpl;)V
    .registers 1
    .param p0, "x0"    # Lcom/android/server/lights/LightsService$LightImpl;

    .line 35
    invoke-direct {p0}, Lcom/android/server/lights/LightsService$LightImpl;->stopFlashing()V

    return-void
.end method

.method private setLightLocked(IIIII)V
    .registers 14
    .param p1, "color"    # I
    .param p2, "mode"    # I
    .param p3, "onMS"    # I
    .param p4, "offMS"    # I
    .param p5, "brightnessMode"    # I

    .line 168
    invoke-direct {p0}, Lcom/android/server/lights/LightsService$LightImpl;->shouldBeInLowPersistenceMode()Z

    move-result v0

    if-eqz v0, :cond_8

    .line 169
    const/4 p5, 0x2

    goto :goto_d

    .line 170
    :cond_8
    const/4 v0, 0x2

    if-ne p5, v0, :cond_d

    .line 171
    iget p5, p0, Lcom/android/server/lights/LightsService$LightImpl;->mLastBrightnessMode:I

    .line 174
    :cond_d
    :goto_d
    iget-boolean v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mInitialized:Z

    if-eqz v0, :cond_25

    iget v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mColor:I

    if-ne p1, v0, :cond_25

    iget v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mMode:I

    if-ne p2, v0, :cond_25

    iget v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mOnMS:I

    if-ne p3, v0, :cond_25

    iget v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mOffMS:I

    if-ne p4, v0, :cond_25

    iget v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mBrightnessMode:I

    if-eq v0, p5, :cond_6f

    .line 178
    :cond_25
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mInitialized:Z

    .line 179
    iget v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mColor:I

    iput v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mLastColor:I

    .line 180
    iput p1, p0, Lcom/android/server/lights/LightsService$LightImpl;->mColor:I

    .line 181
    iput p2, p0, Lcom/android/server/lights/LightsService$LightImpl;->mMode:I

    .line 182
    iput p3, p0, Lcom/android/server/lights/LightsService$LightImpl;->mOnMS:I

    .line 183
    iput p4, p0, Lcom/android/server/lights/LightsService$LightImpl;->mOffMS:I

    .line 184
    iput p5, p0, Lcom/android/server/lights/LightsService$LightImpl;->mBrightnessMode:I

    .line 185
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string/jumbo v1, "setLight("

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v1, p0, Lcom/android/server/lights/LightsService$LightImpl;->mId:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, ", 0x"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 186
    invoke-static {p1}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 185
    const-wide/32 v6, 0x20000

    invoke-static {v6, v7, v0}, Landroid/os/Trace;->traceBegin(JLjava/lang/String;)V

    .line 188
    :try_start_61
    iget v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mId:I

    move v1, p1

    move v2, p2

    move v3, p3

    move v4, p4

    move v5, p5

    invoke-static/range {v0 .. v5}, Lcom/android/server/lights/LightsService;->setLight_native(IIIIII)V
    :try_end_6b
    .catchall {:try_start_61 .. :try_end_6b} :catchall_70

    .line 190
    invoke-static {v6, v7}, Landroid/os/Trace;->traceEnd(J)V

    .line 191
    nop

    .line 193
    :cond_6f
    return-void

    .line 190
    :catchall_70
    move-exception v0

    invoke-static {v6, v7}, Landroid/os/Trace;->traceEnd(J)V

    throw v0
.end method

.method private shouldBeInLowPersistenceMode()Z
    .registers 2

    .line 196
    iget-boolean v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mVrModeEnabled:Z

    if-eqz v0, :cond_a

    iget-boolean v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mUseLowPersistenceForVR:Z

    if-eqz v0, :cond_a

    const/4 v0, 0x1

    goto :goto_b

    :cond_a
    const/4 v0, 0x0

    :goto_b
    return v0
.end method

.method private stopFlashing()V
    .registers 7

    .line 162
    monitor-enter p0

    .line 163
    :try_start_1
    iget v1, p0, Lcom/android/server/lights/LightsService$LightImpl;->mColor:I

    const/4 v2, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v0, p0

    invoke-direct/range {v0 .. v5}, Lcom/android/server/lights/LightsService$LightImpl;->setLightLocked(IIIII)V

    .line 164
    monitor-exit p0

    .line 165
    return-void

    .line 164
    :catchall_d
    move-exception v0

    monitor-exit p0
    :try_end_f
    .catchall {:try_start_1 .. :try_end_f} :catchall_d

    throw v0
.end method


# virtual methods
.method public pulse()V
    .registers 3

    .line 119
    const v0, 0xffffff

    const/4 v1, 0x7

    invoke-virtual {p0, v0, v1}, Lcom/android/server/lights/LightsService$LightImpl;->pulse(II)V

    .line 120
    return-void
.end method

.method public pulse(II)V
    .registers 10
    .param p1, "color"    # I
    .param p2, "onMS"    # I

    .line 124
    monitor-enter p0

    .line 125
    :try_start_1
    iget v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mColor:I

    if-nez v0, :cond_2b

    iget-boolean v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mFlashing:Z

    if-nez v0, :cond_2b

    .line 126
    const/4 v3, 0x2

    const/16 v5, 0x3e8

    const/4 v6, 0x0

    move-object v1, p0

    move v2, p1

    move v4, p2

    invoke-direct/range {v1 .. v6}, Lcom/android/server/lights/LightsService$LightImpl;->setLightLocked(IIIII)V

    .line 128
    const/4 v0, 0x0

    iput v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mColor:I

    .line 129
    iget-object v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->this$0:Lcom/android/server/lights/LightsService;

    # getter for: Lcom/android/server/lights/LightsService;->mH:Landroid/os/Handler;
    invoke-static {v0}, Lcom/android/server/lights/LightsService;->access$000(Lcom/android/server/lights/LightsService;)Landroid/os/Handler;

    move-result-object v0

    iget-object v1, p0, Lcom/android/server/lights/LightsService$LightImpl;->this$0:Lcom/android/server/lights/LightsService;

    # getter for: Lcom/android/server/lights/LightsService;->mH:Landroid/os/Handler;
    invoke-static {v1}, Lcom/android/server/lights/LightsService;->access$000(Lcom/android/server/lights/LightsService;)Landroid/os/Handler;

    move-result-object v1

    const/4 v2, 0x1

    invoke-static {v1, v2, p0}, Landroid/os/Message;->obtain(Landroid/os/Handler;ILjava/lang/Object;)Landroid/os/Message;

    move-result-object v1

    int-to-long v2, p2

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->sendMessageDelayed(Landroid/os/Message;J)Z

    .line 131
    :cond_2b
    monitor-exit p0

    .line 132
    return-void

    .line 131
    :catchall_2d
    move-exception v0

    monitor-exit p0
    :try_end_2f
    .catchall {:try_start_1 .. :try_end_2f} :catchall_2d

    throw v0
.end method

.method public setBrightness(I)V
    .registers 3
    .param p1, "brightness"    # I

    .line 43
    const/4 v0, 0x0

    invoke-virtual {p0, p1, v0}, Lcom/android/server/lights/LightsService$LightImpl;->setBrightness(II)V

    .line 44
    return-void
.end method

.method public setBrightness(II)V
    .registers 18
    .param p1, "brightness"    # I
    .param p2, "brightnessMode"    # I

    move-object v7, p0

    move/from16 v8, p1

    .line 48
    monitor-enter p0

    .line 50
    const/4 v0, 0x2

    move/from16 v9, p2

    if-ne v9, v0, :cond_33

    .line 51
    :try_start_9
    const-string v0, "LightsService"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string/jumbo v2, "setBrightness with LOW_PERSISTENCE unexpected #"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget v2, v7, Lcom/android/server/lights/LightsService$LightImpl;->mId:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v2, ": brightness=0x"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 52
    invoke-static/range {p1 .. p1}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    .line 51
    invoke-static {v0, v1}, Landroid/util/Slog;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 53
    monitor-exit p0

    return-void

    .line 100
    :catchall_30
    move-exception v0

    goto/16 :goto_10f

    .line 56
    :cond_33
    const-string/jumbo v0, "persist.display.rom_max_brightness"

    const/16 v1, 0xff

    invoke-static {v0, v1}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v0

    .line 57
    .local v0, "rom_max_brightness":I
    iget v2, v7, Lcom/android/server/lights/LightsService$LightImpl;->mId:I

    const-wide v3, 0x406fe00000000000L    # 255.0

    if-nez v2, :cond_f4

    .line 58
    const-string/jumbo v2, "ro.vendor.build.fingerprint"

    const-string v5, "hello"

    invoke-static {v2, v5}, Landroid/os/SystemProperties;->get(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    move-object v10, v2

    .line 59
    .local v10, "fp":Ljava/lang/String;
    const-string v2, ".*astarqlte.*"

    invoke-virtual {v10, v2}, Ljava/lang/String;->matches(Ljava/lang/String;)Z

    move-result v2

    const/4 v5, 0x0

    if-eqz v2, :cond_7b

    .line 60
    int-to-double v1, v8

    int-to-double v11, v0

    div-double/2addr v11, v3

    div-double/2addr v1, v11

    double-to-int v1, v1

    .line 61
    .local v1, "newBrightness":I
    const-string/jumbo v2, "persist.sys.samsung.full_brightness"

    invoke-static {v2, v5}, Landroid/os/SystemProperties;->getBoolean(Ljava/lang/String;Z)Z

    move-result v2

    if-eqz v2, :cond_6f

    .line 62
    int-to-double v5, v8

    const-wide v11, 0x4076d00000000000L    # 365.0

    mul-double/2addr v5, v11

    div-double/2addr v5, v3

    double-to-int v1, v5

    .line 64
    .end local v1    # "newBrightness":I
    .local v11, "newBrightness":I
    :cond_6f
    move v11, v1

    const/4 v3, 0x2

    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v1, v7

    move v2, v11

    move v6, v9

    invoke-direct/range {v1 .. v6}, Lcom/android/server/lights/LightsService$LightImpl;->setLightLocked(IIIII)V

    .line 65
    monitor-exit p0

    return-void

    .line 68
    .end local v11    # "newBrightness":I
    :cond_7b
    const-string/jumbo v2, "persist.sys.phh.samsung_backlight"

    invoke-static {v2, v5}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v2

    const/4 v6, 0x1

    if-eq v2, v6, :cond_d2

    const-string v2, ".*beyond.*lte.*"

    .line 69
    invoke-virtual {v10, v2}, Ljava/lang/String;->matches(Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_d2

    const-string v2, ".*(crown|star)[q2]*lte.*"

    .line 70
    invoke-virtual {v10, v2}, Ljava/lang/String;->matches(Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_d2

    const-string v2, ".*(SC-0[23]K|SCV3[89]).*"

    .line 71
    invoke-virtual {v10, v2}, Ljava/lang/String;->matches(Ljava/lang/String;)Z

    move-result v2

    if-eqz v2, :cond_9e

    goto :goto_d2

    .line 80
    :cond_9e
    const-string/jumbo v2, "persist.extend.brightness"

    invoke-static {v2, v5}, Landroid/os/SystemProperties;->getBoolean(Ljava/lang/String;Z)Z

    move-result v2

    .line 81
    .local v2, "qcomExtendBrightness":Z
    const-string/jumbo v5, "persist.display.max_brightness"

    const/16 v6, 0x3ff

    invoke-static {v5, v6}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v5

    .line 83
    .local v5, "scale":I
    const-string/jumbo v6, "persist.sys.qcom-brightness"

    const/4 v11, -0x1

    invoke-static {v6, v11}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I

    move-result v6

    move v12, v6

    .line 84
    .local v12, "qcomScale":I
    if-eq v12, v11, :cond_bb

    .line 85
    const/4 v2, 0x1

    .line 86
    move v5, v12

    .line 89
    .end local v2    # "qcomExtendBrightness":Z
    .end local v5    # "scale":I
    .local v11, "qcomExtendBrightness":Z
    .local v13, "scale":I
    :cond_bb
    move v11, v2

    move v13, v5

    if-eqz v11, :cond_f4

    .line 90
    mul-int v1, v8, v13

    int-to-double v1, v1

    div-double/2addr v1, v3

    int-to-double v5, v0

    div-double/2addr v5, v3

    div-double/2addr v1, v5

    double-to-int v14, v1

    .line 91
    .local v14, "newBrightness":I
    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v1, v7

    move v2, v14

    move v6, v9

    invoke-direct/range {v1 .. v6}, Lcom/android/server/lights/LightsService$LightImpl;->setLightLocked(IIIII)V

    .line 92
    monitor-exit p0

    return-void

    .line 72
    .end local v11    # "qcomExtendBrightness":Z
    .end local v12    # "qcomScale":I
    .end local v13    # "scale":I
    .end local v14    # "newBrightness":I
    :cond_d2
    :goto_d2
    mul-int/lit8 v1, v8, 0x64

    int-to-double v1, v1

    int-to-double v11, v0

    div-double/2addr v11, v3

    div-double/2addr v1, v11

    double-to-int v1, v1

    .line 73
    .restart local v1    # "newBrightness":I
    const-string/jumbo v2, "persist.sys.samsung.full_brightness"

    invoke-static {v2, v5}, Landroid/os/SystemProperties;->getBoolean(Ljava/lang/String;Z)Z

    move-result v2

    if-eqz v2, :cond_e8

    .line 74
    int-to-double v5, v8

    const-wide/high16 v11, 0x40e4000000000000L    # 40960.0

    mul-double/2addr v5, v11

    div-double/2addr v5, v3

    double-to-int v1, v5

    .line 76
    .end local v1    # "newBrightness":I
    .local v11, "newBrightness":I
    :cond_e8
    move v11, v1

    const/4 v3, 0x2

    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v1, v7

    move v2, v11

    move v6, v9

    invoke-direct/range {v1 .. v6}, Lcom/android/server/lights/LightsService$LightImpl;->setLightLocked(IIIII)V

    .line 77
    monitor-exit p0

    return-void

    .line 96
    .end local v10    # "fp":Ljava/lang/String;
    .end local v11    # "newBrightness":I
    :cond_f4
    int-to-double v5, v8

    int-to-double v10, v0

    div-double/2addr v10, v3

    div-double/2addr v5, v10

    double-to-int v2, v5

    .line 97
    .local v2, "color":I
    and-int/2addr v1, v2

    .line 98
    .end local v2    # "color":I
    .local v1, "color":I
    const/high16 v2, -0x1000000

    shl-int/lit8 v3, v1, 0x10

    or-int/2addr v2, v3

    shl-int/lit8 v3, v1, 0x8

    or-int/2addr v2, v3

    or-int v10, v2, v1

    .line 99
    .end local v1    # "color":I
    .local v10, "color":I
    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v1, v7

    move v2, v10

    move v6, v9

    invoke-direct/range {v1 .. v6}, Lcom/android/server/lights/LightsService$LightImpl;->setLightLocked(IIIII)V

    .line 100
    .end local v0    # "rom_max_brightness":I
    .end local v10    # "color":I
    monitor-exit p0

    .line 101
    return-void

    .line 100
    :goto_10f
    monitor-exit p0
    :try_end_110
    .catchall {:try_start_9 .. :try_end_110} :catchall_30

    throw v0
.end method

.method public setColor(I)V
    .registers 8
    .param p1, "color"    # I

    .line 105
    monitor-enter p0

    .line 106
    const/4 v2, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v0, p0

    move v1, p1

    :try_start_7
    invoke-direct/range {v0 .. v5}, Lcom/android/server/lights/LightsService$LightImpl;->setLightLocked(IIIII)V

    .line 107
    monitor-exit p0

    .line 108
    return-void

    .line 107
    :catchall_c
    move-exception v0

    monitor-exit p0
    :try_end_e
    .catchall {:try_start_7 .. :try_end_e} :catchall_c

    throw v0
.end method

.method public setFlashing(IIII)V
    .registers 11
    .param p1, "color"    # I
    .param p2, "mode"    # I
    .param p3, "onMS"    # I
    .param p4, "offMS"    # I

    .line 112
    monitor-enter p0

    .line 113
    const/4 v5, 0x0

    move-object v0, p0

    move v1, p1

    move v2, p2

    move v3, p3

    move v4, p4

    :try_start_7
    invoke-direct/range {v0 .. v5}, Lcom/android/server/lights/LightsService$LightImpl;->setLightLocked(IIIII)V

    .line 114
    monitor-exit p0

    .line 115
    return-void

    .line 114
    :catchall_c
    move-exception v0

    monitor-exit p0
    :try_end_e
    .catchall {:try_start_7 .. :try_end_e} :catchall_c

    throw v0
.end method

.method public setVrMode(Z)V
    .registers 3
    .param p1, "enabled"    # Z

    .line 143
    monitor-enter p0

    .line 144
    :try_start_1
    iget-boolean v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mVrModeEnabled:Z

    if-eq v0, p1, :cond_1e

    .line 145
    iput-boolean p1, p0, Lcom/android/server/lights/LightsService$LightImpl;->mVrModeEnabled:Z

    .line 147
    iget-object v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->this$0:Lcom/android/server/lights/LightsService;

    .line 148
    # invokes: Lcom/android/server/lights/LightsService;->getVrDisplayMode()I
    invoke-static {v0}, Lcom/android/server/lights/LightsService;->access$100(Lcom/android/server/lights/LightsService;)I

    move-result v0

    if-nez v0, :cond_11

    const/4 v0, 0x1

    goto :goto_12

    :cond_11
    const/4 v0, 0x0

    :goto_12
    iput-boolean v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mUseLowPersistenceForVR:Z

    .line 149
    invoke-direct {p0}, Lcom/android/server/lights/LightsService$LightImpl;->shouldBeInLowPersistenceMode()Z

    move-result v0

    if-eqz v0, :cond_1e

    .line 150
    iget v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mBrightnessMode:I

    iput v0, p0, Lcom/android/server/lights/LightsService$LightImpl;->mLastBrightnessMode:I

    .line 158
    :cond_1e
    monitor-exit p0

    .line 159
    return-void

    .line 158
    :catchall_20
    move-exception v0

    monitor-exit p0
    :try_end_22
    .catchall {:try_start_1 .. :try_end_22} :catchall_20

    throw v0
.end method

.method public turnOff()V
    .registers 7

    .line 136
    monitor-enter p0

    .line 137
    const/4 v1, 0x0

    const/4 v2, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    move-object v0, p0

    :try_start_7
    invoke-direct/range {v0 .. v5}, Lcom/android/server/lights/LightsService$LightImpl;->setLightLocked(IIIII)V

    .line 138
    monitor-exit p0

    .line 139
    return-void

    .line 138
    :catchall_c
    move-exception v0

    monitor-exit p0
    :try_end_e
    .catchall {:try_start_7 .. :try_end_e} :catchall_c

    throw v0
.end method
