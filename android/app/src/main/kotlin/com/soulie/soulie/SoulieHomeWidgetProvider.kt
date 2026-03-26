package com.soulie.soulie

import android.content.Context
import android.net.Uri
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.actionStartActivity
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.action.clickable
import androidx.glance.appwidget.components.Text
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.layout.wrapContentHeight
import androidx.glance.text.FontWeight
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

class SoulieHomeWidgetProvider : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = SoulieHomeWidget()
}

private data class SoulieWidgetData(
    val title: String,
    val subtitle: String,
    val highlight: String,
    val friends: String,
    val imagePath: String?,
    val notificationCount: Int,
)

class SoulieHomeWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: androidx.glance.GlanceId) {
        provideContent {
            val state = currentState<HomeWidgetGlanceState>()
            val prefs = state.preferences
            val data = SoulieWidgetData(
                title = prefs.getString("title", "Soulie") ?: "Soulie",
                subtitle = prefs.getString("subtitle", "Your private photo pulse")
                    ?: "Your private photo pulse",
                highlight = prefs.getString("highlight", "Share a tiny window into your day.")
                    ?: "Share a tiny window into your day.",
                friends = prefs.getString("friends", "Open Soulie to reconnect.")
                    ?: "Open Soulie to reconnect.",
                imagePath = prefs.getString("soulie_widget_image", null),
                notificationCount = prefs.getInt("notificationCount", 0),
            )
            val size = LocalSize.current
            val useMediumLayout = size.width >= 220.dp || size.height >= 220.dp

            if (useMediumLayout) {
                MediumWidgetLayout(data = data)
            } else {
                SmallWidgetLayout(data = data)
            }
        }
    }
}

@androidx.compose.runtime.Composable
private fun SmallWidgetLayout(data: SoulieWidgetData) {
    val title = if (data.highlight.isNotBlank()) data.highlight else data.subtitle
    val footer = if (data.friends.isNotBlank()) data.friends else "Tap to open messages"

    Box(
        modifier = widgetContainer()
            .background(Color(0xFF120F17))
            .cornerRadius(30.dp),
        contentAlignment = Alignment.BottomStart,
    ) {
        PhotoBackground(data = data, overlayAlpha = 0.6f)

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(14.dp),
        ) {
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                LabelChip(text = "SOULIE")
                Spacer(modifier = GlanceModifier.defaultWeight())
                if (data.notificationCount > 0) {
                    UnreadBadge(count = data.notificationCount)
                }
            }

            Spacer(modifier = GlanceModifier.defaultWeight())

            Text(
                text = title,
                maxLines = 2,
                style = TextStyle(
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 19.sp,
                ),
            )
            Spacer(modifier = GlanceModifier.height(6.dp))
            Text(
                text = footer,
                maxLines = 1,
                style = TextStyle(
                    color = Color(0xDBFFFFFF),
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 11.sp,
                ),
            )
        }
    }
}

@androidx.compose.runtime.Composable
private fun MediumWidgetLayout(data: SoulieWidgetData) {
    Box(
        modifier = widgetContainer()
            .background(Color(0xFF120F17))
            .cornerRadius(30.dp),
    ) {
        Row(modifier = GlanceModifier.fillMaxSize()) {
            Box(
                modifier = GlanceModifier
                    .fillMaxHeight()
                    .width(154.dp),
                contentAlignment = Alignment.BottomStart,
            ) {
                PhotoBackground(data = data, overlayAlpha = 0.4f)

                Column(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .padding(16.dp),
                ) {
                    Text(
                        text = data.title,
                        maxLines = 1,
                        style = TextStyle(
                            color = Color.White,
                            fontWeight = FontWeight.Bold,
                            fontSize = 20.sp,
                        ),
                    )
                    Spacer(modifier = GlanceModifier.height(4.dp))
                    Text(
                        text = data.subtitle,
                        maxLines = 2,
                        style = TextStyle(
                            color = Color(0xCCFFFFFF),
                            fontWeight = FontWeight.Medium,
                            fontSize = 11.sp,
                        ),
                    )
                }
            }

            Column(
                modifier = GlanceModifier
                    .fillMaxHeight()
                    .defaultWeight()
                    .background(Color(0xFF17121E))
                    .padding(16.dp),
            ) {
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    LabelChip(text = "LOCKET FEEL")
                    Spacer(modifier = GlanceModifier.defaultWeight())
                    if (data.notificationCount > 0) {
                        UnreadBadge(count = data.notificationCount)
                    }
                }

                Spacer(modifier = GlanceModifier.height(14.dp))

                Text(
                    text = "LIVE VIBE",
                    style = TextStyle(
                        color = Color(0xFFFFBCD0),
                        fontWeight = FontWeight.Bold,
                        fontSize = 10.sp,
                    ),
                )
                Spacer(modifier = GlanceModifier.height(6.dp))
                Text(
                    text = data.highlight,
                    maxLines = 4,
                    style = TextStyle(
                        color = Color.White,
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 15.sp,
                    ),
                )

                Spacer(modifier = GlanceModifier.height(16.dp))

                Text(
                    text = "CLOSE FRIENDS",
                    style = TextStyle(
                        color = Color(0x8AFFFFFF),
                        fontWeight = FontWeight.Bold,
                        fontSize = 10.sp,
                    ),
                )
                Spacer(modifier = GlanceModifier.height(8.dp))

                FriendChip(name = friendNames(data).getOrElse(0) { "Soulie" })
                Spacer(modifier = GlanceModifier.height(6.dp))
                FriendChip(name = friendNames(data).getOrElse(1) { "Friends" })
                if (friendNames(data).size > 2) {
                    Spacer(modifier = GlanceModifier.height(6.dp))
                    FriendChip(name = friendNames(data)[2])
                }

                Spacer(modifier = GlanceModifier.defaultWeight())

                Text(
                    text = "Tap to jump into messages",
                    maxLines = 1,
                    style = TextStyle(
                        color = Color(0xBDFFFFFF),
                        fontWeight = FontWeight.Medium,
                        fontSize = 11.sp,
                    ),
                )
            }
        }
    }
}

@androidx.compose.runtime.Composable
private fun PhotoBackground(data: SoulieWidgetData, overlayAlpha: Float) {
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Color(0xFF201628)),
    ) {
        if (data.imagePath != null) {
            Image(
                provider = ImageProvider(data.imagePath),
                contentDescription = "Soulie moment",
                modifier = GlanceModifier.fillMaxSize(),
            )
        } else {
            Box(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(Color(0xFF2A1D33)),
            ) {
                Column(
                    modifier = GlanceModifier.fillMaxSize(),
                    verticalAlignment = Alignment.Vertical.CenterVertically,
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                ) {
                    Text(
                        text = "Soulie",
                        style = TextStyle(
                            color = Color.White,
                            fontWeight = FontWeight.Bold,
                            fontSize = 19.sp,
                        ),
                    )
                    Spacer(modifier = GlanceModifier.height(6.dp))
                    Text(
                        text = "camera drop",
                        style = TextStyle(
                            color = Color(0xCCFFFFFF),
                            fontSize = 11.sp,
                        ),
                    )
                }
            }
        }

        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ColorProviderWithAlpha(overlayAlpha)),
        ) {}
    }
}

@androidx.compose.runtime.Composable
private fun LabelChip(text: String) {
    Box(
        modifier = GlanceModifier
            .background(Color(0x36000000))
            .cornerRadius(999.dp)
            .padding(horizontal = 8.dp, vertical = 5.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = text,
            style = TextStyle(
                color = Color.White,
                fontWeight = FontWeight.Bold,
                fontSize = 9.sp,
                textAlign = TextAlign.Center,
            ),
        )
    }
}

@androidx.compose.runtime.Composable
private fun UnreadBadge(count: Int) {
    Box(
        modifier = GlanceModifier
            .background(Color(0xFFFF85A2))
            .cornerRadius(999.dp)
            .padding(horizontal = 9.dp, vertical = 5.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = if (count > 99) "99+" else count.toString(),
            style = TextStyle(
                color = Color.White,
                fontWeight = FontWeight.Bold,
                fontSize = 11.sp,
            ),
        )
    }
}

@androidx.compose.runtime.Composable
private fun FriendChip(name: String) {
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .wrapContentHeight()
            .background(Color(0x16FFFFFF))
            .cornerRadius(999.dp)
            .padding(horizontal = 8.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = GlanceModifier
                .width(18.dp)
                .height(18.dp)
                .background(Color(0xFFFF85A2))
                .cornerRadius(999.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                text = name.take(1).uppercase(),
                style = TextStyle(
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 9.sp,
                ),
            )
        }
        Spacer(modifier = GlanceModifier.width(6.dp))
        Text(
            text = name,
            maxLines = 1,
            style = TextStyle(
                color = Color(0xE6FFFFFF),
                fontWeight = FontWeight.Medium,
                fontSize = 11.sp,
            ),
        )
    }
}

private fun widgetContainer(): GlanceModifier = GlanceModifier
    .fillMaxSize()
    .clickable(
        onClick = actionStartActivity<MainActivity>(
            Uri.parse("soulie://messages?homeWidget=1"),
        ),
    )

private fun friendNames(data: SoulieWidgetData): List<String> {
    return data.friends
        .split("•")
        .map { it.trim() }
        .filter { it.isNotEmpty() }
        .take(3)
        .ifEmpty { listOf("Soulie", "Friends") }
}

private fun ColorProviderWithAlpha(alpha: Float): Color {
    return Color(0f, 0f, 0f, alpha)
}
