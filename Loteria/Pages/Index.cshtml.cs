using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using System.Data;


namespace Loteria.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(ILogger<IndexModel> logger)
        {
            _logger = logger;
        }

        public void OnGet()
        {

        }

        [HttpPost]
        public IActionResult OnPostGetAjax(int totalTarjetas)
        {
            int numTarjetasCreadas = 0;

            int totalCartas = getTotalCartas();

            while (numTarjetasCreadas < Math.Abs(totalTarjetas))
            {
                bool tarjetaCreada = false;

                do
                {
                    List<int> elementosTarjeta = getItemsTarjeta(totalCartas);
                    //List<int> elementosTarjeta = new List<int> { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
                    tarjetaCreada = crearTarjeta(elementosTarjeta);
                }
                while (!tarjetaCreada);

                numTarjetasCreadas++;
            }

            string jsonTarjetas = obtenerListadoTarjetas();

            //return new JsonResult("Total de cartas creadas: " + numTarjetasCreadas);

            return new JsonResult(jsonTarjetas);
        }

        private string obtenerListadoTarjetas()
        {
            List<Tarjeta> tarjetas = new List<Tarjeta>();

            SqlConnection sqlConnection = new SqlConnection("Server=localhost\\SQLEXPRESS;Database=Loteria_DB;TrustServerCertificate=True; Trusted_Connection=True;");
            sqlConnection.Open();

            string sp = $"exec ObtenerListadoTarjetas";
            SqlCommand cmd = new SqlCommand(sp, sqlConnection);
            SqlDataReader registros = cmd.ExecuteReader();

            while (registros.Read())
            {
                Tarjeta tarjeta = new Tarjeta(int.Parse(registros["idTarjeta"].ToString()), registros["List_Output"].ToString());
                tarjetas.Add(tarjeta);
            }
            sqlConnection.Close();

            var resultado = new { resultado = tarjetas };

            return JsonConvert.SerializeObject(resultado);
        }

        private bool crearTarjeta(List<int> elementosTarjeta)
        {
            string strElementosTarjeta = string.Join(",", elementosTarjeta);

            SqlConnection sqlConnection = new SqlConnection("Server=localhost\\SQLEXPRESS;Database=Loteria_DB;TrustServerCertificate=True; Trusted_Connection=True;");
            sqlConnection.Open();

            string sp = $"exec AgregarTarjeta '{strElementosTarjeta}'";

            SqlCommand cmd = new SqlCommand(sp, sqlConnection);
            SqlDataReader registros = cmd.ExecuteReader();
            bool tarjetaValida = false;
            while (registros.Read())
            {
                tarjetaValida = bool.Parse(registros["tarjetaValida"].ToString());
                break;
            }
            sqlConnection.Close();

            return tarjetaValida;
        }

        private List<int> getItemsTarjeta(int totalCartas)
        {
            int numElementosTarjeta = 16;
            List<int> cartas = Enumerable.Range(1, totalCartas).ToList();
            List<int> elementosTarjeta = cartas.OrderBy(x => Guid.NewGuid()).Take(numElementosTarjeta).ToList();
            return elementosTarjeta;
        }

        private int getTotalCartas()
        {
            SqlConnection sqlConnection = new SqlConnection("Server=localhost\\SQLEXPRESS;Database=Loteria_DB;TrustServerCertificate=True; Trusted_Connection=True;");
            sqlConnection.Open();

            string sp = "exec ObtenerTotalCartas";

            SqlCommand cmd = new SqlCommand(sp, sqlConnection);
            SqlDataReader registros = cmd.ExecuteReader();
            int totalCartas = 0;
            while (registros.Read())
            {
                totalCartas = int.Parse(registros["totalCartas"].ToString());
                break;
            }
            sqlConnection.Close();

            return totalCartas;
        }
    }
}