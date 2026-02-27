import { LoginForm } from "../components/login-form/LoginForm";
import amico from "../assets/amico.svg";

const Login = () => {
  return (
    <div className="min-h-screen flex justify-center bg-vita-white ">
      <div className="flex flex-col justify-center gap-20">
        <div>
          <h1 className="text-title text-vita-black">Iniciar sesión</h1>
        </div>
        <div className="flex items-start justify-between bg-vita-white flex-row w-full gap-28">
          <div className="text-center pt-12">
            <LoginForm />
          </div>
          <div style={{ width: "662px", height: "640px" }}>
            <img
              src={amico}
              alt="Login illustration"
              className="hidden md:block w-full h-full object-cover"
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default Login;
