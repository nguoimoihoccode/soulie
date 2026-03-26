package com.soulie.soulie

import android.content.Context
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.components.Text
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

class SoulieHomeWidgetProvider : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = SoulieHomeWidget()
}

class SoulieHomeWidget : GlanceAppWidget() {
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: androidx.glance.GlanceId) {
        provideContent {
            val state = currentState<HomeWidgetGlanceState>()
            val prefs = state.preferences
            val title = prefs.getString("title", "Soulie") ?: "Soulie"
            val subtitle = prefs.getString("subtitle", "Your private photo pulse")
                ?: "Your private photo pulse"
            val highlight = prefs.getString("highlight", "Share a tiny window into your day.")
                ?: "Share a tiny window into your day."
            val friends = prefs.getString("friends", "Open Soulie to reconnect.")
                ?: "Open Soulie to reconnect."
            val imagePath = prefs.getString("soulie_widget_image", null)

            Box(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(Color(0xFF120F17))
                    .padding(16.dp),
            ) {
                Column(modifier = GlanceModifier.fillMaxSize()) {
                    Text(
                        text = title,
                        style = TextStyle(
                            color = Color.White,
                            fontWeight = FontWeight.Bold,
                        ),
                    )
                    Spacer(modifier = GlanceModifier.height(6.dp))
                    Text(
                        text = subtitle,
                        style = TextStyle(color = Color(0xFFD7C8E5)),
                        maxLines = 2,
                    )
                    Spacer(modifier = GlanceModifier.height(14.dp))
                    imagePath?.let { path ->
                        Image(
                            provider = ImageProvider(path),
                            contentDescription = "Soulie widget preview",
                            modifier = GlanceModifier
                                .fillMaxWidth()
                                .height(140.dp),
                        )
                        Spacer(modifier = GlanceModifier.height(14.dp))
                    }
                    Text(
                        text = highlight,
                        style = TextStyle(
                            color = Color.White,
                            fontWeight = FontWeight.Medium,
                        ),
                        maxLines = 3,
                    )
                    Spacer(modifier = GlanceModifier.height(10.dp))
                    Text(
                        text = friends,
                        style = TextStyle(color = Color(0xFFB8A8C9)),
                        maxLines = 2,
                    )
                }
            }
        }
    }
}
