#include "../GCPVideoRenderer.h"
#include "PluginWindowX11.h"
#include <iostream>

namespace GoCast
{
    gboolean RedrawWindow(gpointer data)
    {
        GCPVideoRenderer* pRenderer = reinterpret_cast<GCPVideoRenderer*>(data);
        return pRenderer->OnWindowRefresh();
    }
    
    bool GCPVideoRenderer::RenderFrame(const cricket::VideoFrame* pFrame)
    {
        static const int stride = m_width*4;
        static const int frameBufferSize = m_height*stride;
        boost::mutex::scoped_lock winLock(m_winMutex);
        
        pFrame->ConvertToRgbBuffer(cricket::FOURCC_ARGB,
                                   m_pFrameBuffer.get(),
                                   frameBufferSize,
                                   stride);
        
        //convert to rgba and correct alpha
        uint8* pBufIter = m_pFrameBuffer.get();
        uint8* pBufEnd = pBufIter + frameBufferSize;
        while(pBufIter < pBufEnd)
        {
            pBufIter[3] = pBufIter[0];
            pBufIter[0] = pBufIter[2];
            pBufIter[2] = pBufIter[3];
            pBufIter[3] = 0xff;
            pBufIter += 4;
        }
        
        //trigger window refresh event
        g_idle_add(RedrawWindow, this);
        
        return true;
    }
    
    bool GCPVideoRenderer::OnWindowRefresh(FB::RefreshEvent* pEvt)
    {
        FB::PluginWindowX11* pWinX11 = NULL;
        boost::mutex::scoped_lock winLock(m_winMutex);
		int width = m_pWin->getWindowWidth();
		int height = m_pWin->getWindowHeight();

        pWinX11 = dynamic_cast<FB::PluginWindowX11*>(m_pWin);
        if(NULL != pWinX11)
        {
            GtkWidget* pRenderArea = pWinX11->getWidget();
            if(NULL != pRenderArea)
            {
                gdk_draw_rgb_32_image(
                    pRenderArea->window,
                    pRenderArea->style->fg_gc[GTK_STATE_NORMAL],
                    0,
                    0,
                    width,
                    height,
                    GDK_RGB_DITHER_MAX,
                    m_pFrameBuffer.get(),
                    m_width*4
                );
            }
        }
 
        return true;
    }
}
