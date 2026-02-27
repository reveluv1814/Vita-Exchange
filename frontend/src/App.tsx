import { router } from "./routes";
import "./App.css";
import { RouterProvider } from "react-router-dom";
import { AuthProvider } from "./context/authContext.tsx";
import { PreviewProvider } from "./context/previewContext.tsx";
import { Toaster } from "./components/ui/sonner";

function App() {
  return (
    <>
      <AuthProvider>
        <PreviewProvider>
          <RouterProvider router={router} />
          <Toaster />
        </PreviewProvider>
      </AuthProvider>
    </>
  );
}

export default App;
