pub const SDLError = error{ Unknown, RenderPresentFailed, RenderTextFailed, CreateTimerError, RenderCopyFailed, TTFInitFailed, CreateWindowFailed, SetRenderDrawColorFailed, RenderClearFailed, CreateTextureFromSurfaceFailed };
pub const EngineError = error{ HttpError, CurlError, StoreLocked };
