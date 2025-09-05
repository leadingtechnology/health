using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using health_api.Models;

namespace health_api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PlansController : ControllerBase
    {
        /// <summary>
        /// Get all subscription plans and their pricing/quotas.
        /// </summary>
        /// <remarks>
        /// Returns Free, Standard, Pro, and Platinum plans with monthly/yearly prices
        /// and feature quotas (text tokens, TTS/STT minutes, images, voice, etc.).
        /// </remarks>
        /// <response code="200">List of plan configurations</response>
        [HttpGet]
        [AllowAnonymous]
        [ProducesResponseType(typeof(IEnumerable<PlanConfiguration>), StatusCodes.Status200OK)]
        public ActionResult<IEnumerable<PlanConfiguration>> GetPlans()
        {
            var plans = PlanConfigurations.Configurations.Values
                .OrderBy(p => p.Plan) // Free, Standard, Pro, Platinum
                .ToList();
            return Ok(plans);
        }
    }
}
