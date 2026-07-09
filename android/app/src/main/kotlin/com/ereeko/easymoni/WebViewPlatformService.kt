package com.ereeko.easymoni

import android.graphics.Bitmap
import android.net.http.SslError
import android.os.Build
import android.util.Log
import android.view.ViewGroup
import android.webkit.RenderProcessGoneDetail
import android.webkit.SslErrorHandler
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi

// WebView 平台保护：处理 Android 渲染进程退出，避免 H5 异常拖垮宿主 App。
internal class WebViewPlatformService(private val flutterEngine: FlutterEngine) {
    private lateinit var channel: MethodChannel

    fun register(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, NativeChannels.WEBVIEW)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "protectWebViewRenderer" -> {
                    val identifier = call.argument<Number>("identifier")?.toLong()
                    if (identifier == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    result.success(protectWebViewRenderer(identifier))
                }
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun protectWebViewRenderer(identifier: Long): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false

        val webView = WebViewFlutterAndroidExternalApi.getWebView(flutterEngine, identifier)
            ?: return false
        if (webView.webViewClient is RendererSafeWebViewClient) return true

        webView.webViewClient = RendererSafeWebViewClient(
            identifier = identifier,
            delegate = webView.webViewClient,
            channel = channel
        )
        return true
    }
}

@RequiresApi(Build.VERSION_CODES.O)
private class RendererSafeWebViewClient(
    private val identifier: Long,
    private val delegate: WebViewClient?,
    private val channel: MethodChannel
) : WebViewClient() {
    override fun onPageStarted(view: WebView, url: String, favicon: Bitmap?) {
        delegate?.onPageStarted(view, url, favicon)
    }

    override fun onPageFinished(view: WebView, url: String) {
        delegate?.onPageFinished(view, url)
    }

    override fun onReceivedError(
        view: WebView,
        request: WebResourceRequest,
        error: WebResourceError
    ) {
        delegate?.onReceivedError(view, request, error)
    }

    override fun onReceivedHttpError(
        view: WebView,
        request: WebResourceRequest,
        errorResponse: WebResourceResponse
    ) {
        delegate?.onReceivedHttpError(view, request, errorResponse)
    }

    override fun onReceivedSslError(view: WebView, handler: SslErrorHandler, error: SslError) {
        delegate?.onReceivedSslError(view, handler, error)
    }

    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        return delegate?.shouldOverrideUrlLoading(view, request) ?: false
    }

    @Deprecated("Deprecated in Java")
    @Suppress("DEPRECATION")
    override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
        return delegate?.shouldOverrideUrlLoading(view, url) ?: false
    }

    override fun onRenderProcessGone(view: WebView, detail: RenderProcessGoneDetail): Boolean {
        Log.e(
            "WebViewPlatformService",
            "WebView renderer gone, didCrash=${detail.didCrash()}, id=$identifier"
        )
        (view.parent as? ViewGroup)?.removeView(view)
        view.destroy()
        channel.invokeMethod(
            "onRenderProcessGone",
            mapOf(
                "identifier" to identifier,
                "didCrash" to detail.didCrash()
            )
        )
        return true
    }
}
