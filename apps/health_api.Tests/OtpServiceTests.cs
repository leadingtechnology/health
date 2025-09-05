using System.Text.RegularExpressions;
using health_api.Services;
using Xunit;

namespace health_api.Tests
{
    public class OtpServiceTests
    {
        private static OtpService CreateSvc() => new OtpService(db: null!, logger: null!, config: null!);

        [Fact]
        public void GenerateOtpCode_Default_IsSixDigits()
        {
            var svc = CreateSvc();
            var code = svc.GenerateOtpCode();
            Assert.NotNull(code);
            Assert.Equal(6, code.Length);
            Assert.Matches(new Regex("^[0-9]{6}$"), code);
        }

        [Fact]
        public void GenerateOtpCode_ClampUnder4_ToSixDigits()
        {
            var svc = CreateSvc();
            var code = svc.GenerateOtpCode(3);
            Assert.Equal(6, code.Length);
            Assert.Matches(new Regex("^[0-9]{6}$"), code);
        }

        [Fact]
        public void GenerateOtpCode_ClampOver10_ToSixDigits()
        {
            var svc = CreateSvc();
            var code = svc.GenerateOtpCode(11);
            Assert.Equal(6, code.Length);
            Assert.Matches(new Regex("^[0-9]{6}$"), code);
        }

        [Fact]
        public void GenerateOtpCode_CustomDigits_AllNumeric()
        {
            var svc = CreateSvc();
            var code = svc.GenerateOtpCode(8);
            Assert.Equal(8, code.Length);
            Assert.Matches(new Regex("^[0-9]{8}$"), code);
        }
    }
}

