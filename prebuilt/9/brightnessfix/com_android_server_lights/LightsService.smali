.class public Lcom/android/server/lights/LightsService;
.super Lcom/android/server/SystemService;
.source "LightsService.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/android/server/lights/LightsService$LightImpl;
    }
.end annotation


# static fields
.field static final DEBUG:Z = false

.field static final TAG:Ljava/lang/String; = "LightsService"


# instance fields
.field private mH:Landroid/os/Handler;

.field final mLights:[Lcom/android/server/lights/LightsService$LightImpl;

.field private final mService:Lcom/android/server/lights/LightsManager;


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .registers 7
    .param p1, "context"    # Landroid/content/Context;

    .line 218
    invoke-direct {p0, p1}, Lcom/android/server/SystemService;-><init>(Landroid/content/Context;)V

    .line 33
    const/16 v0, 0x8

    new-array v1, v0, [Lcom/android/server/lights/LightsService$LightImpl;

    iput-object v1, p0, Lcom/android/server/lights/LightsService;->mLights:[Lcom/android/server/lights/LightsService$LightImpl;

    .line 242
    new-instance v1, Lcom/android/server/lights/LightsService$1;

    invoke-direct {v1, p0}, Lcom/android/server/lights/LightsService$1;-><init>(Lcom/android/server/lights/LightsService;)V

    iput-object v1, p0, Lcom/android/server/lights/LightsService;->mService:Lcom/android/server/lights/LightsManager;

    .line 253
    new-instance v1, Lcom/android/server/lights/LightsService$2;

    invoke-direct {v1, p0}, Lcom/android/server/lights/LightsService$2;-><init>(Lcom/android/server/lights/LightsService;)V

    iput-object v1, p0, Lcom/android/server/lights/LightsService;->mH:Landroid/os/Handler;

    .line 220
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_18
    if-ge v1, v0, :cond_27

    .line 221
    iget-object v2, p0, Lcom/android/server/lights/LightsService;->mLights:[Lcom/android/server/lights/LightsService$LightImpl;

    new-instance v3, Lcom/android/server/lights/LightsService$LightImpl;

    const/4 v4, 0x0

    invoke-direct {v3, p0, v1, v4}, Lcom/android/server/lights/LightsService$LightImpl;-><init>(Lcom/android/server/lights/LightsService;ILcom/android/server/lights/LightsService$1;)V

    aput-object v3, v2, v1

    .line 220
    add-int/lit8 v1, v1, 0x1

    goto :goto_18

    .line 223
    .end local v1    # "i":I
    :cond_27
    return-void
.end method

.method static synthetic access$000(Lcom/android/server/lights/LightsService;)Landroid/os/Handler;
    .registers 2
    .param p0, "x0"    # Lcom/android/server/lights/LightsService;

    .line 29
    iget-object v0, p0, Lcom/android/server/lights/LightsService;->mH:Landroid/os/Handler;

    return-object v0
.end method

.method static synthetic access$100(Lcom/android/server/lights/LightsService;)I
    .registers 2
    .param p0, "x0"    # Lcom/android/server/lights/LightsService;

    .line 29
    invoke-direct {p0}, Lcom/android/server/lights/LightsService;->getVrDisplayMode()I

    move-result v0

    return v0
.end method

.method private getVrDisplayMode()I
    .registers 5

    .line 235
    invoke-static {}, Landroid/app/ActivityManager;->getCurrentUser()I

    move-result v0

    .line 236
    .local v0, "currentUser":I
    invoke-virtual {p0}, Lcom/android/server/lights/LightsService;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const-string/jumbo v2, "vr_display_mode"

    const/4 v3, 0x0

    invoke-static {v1, v2, v3, v0}, Landroid/provider/Settings$Secure;->getIntForUser(Landroid/content/ContentResolver;Ljava/lang/String;II)I

    move-result v1

    return v1
.end method

.method static native setLight_native(IIIIII)V
.end method


# virtual methods
.method public onBootPhase(I)V
    .registers 2
    .param p1, "phase"    # I

    .line 232
    return-void
.end method

.method public onStart()V
    .registers 3

    .line 227
    const-class v0, Lcom/android/server/lights/LightsManager;

    iget-object v1, p0, Lcom/android/server/lights/LightsService;->mService:Lcom/android/server/lights/LightsManager;

    invoke-virtual {p0, v0, v1}, Lcom/android/server/lights/LightsService;->publishLocalService(Ljava/lang/Class;Ljava/lang/Object;)V

    .line 228
    return-void
.end method
