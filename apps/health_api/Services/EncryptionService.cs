using System.Security.Cryptography;
using System.Text;

namespace health_api.Services
{
    /// <summary>
    /// AES-GCM encryption service. Requires env KEYRING_MASTER_KEY (Base64 32 bytes).
    /// Stores blob as base64 of: nonce(12) + tag(16) + ciphertext.
    /// </summary>
    public class EncryptionService
    {
        private readonly byte[] _key;

        public EncryptionService(IConfiguration cfg, ILogger<EncryptionService> logger)
        {
            var b64 = Environment.GetEnvironmentVariable("KEYRING_MASTER_KEY");
            if (string.IsNullOrWhiteSpace(b64))
            {
                logger.LogWarning("KEYRING_MASTER_KEY missing. Generating ephemeral key for dev only.");
                _key = RandomNumberGenerator.GetBytes(32);
            }
            else
            {
                _key = Convert.FromBase64String(b64);
                if (_key.Length != 32) throw new Exception("KEYRING_MASTER_KEY must be 32 bytes Base64");
            }
        }

        public string Encrypt(string plaintext)
        {
            var nonce = RandomNumberGenerator.GetBytes(12);
            using var aes = new AesGcm(_key);
            var pt = Encoding.UTF8.GetBytes(plaintext);
            var ct = new byte[pt.Length];
            var tag = new byte[16];
            aes.Encrypt(nonce, pt, ct, tag);
            var blob = new byte[nonce.Length + tag.Length + ct.Length];
            Buffer.BlockCopy(nonce, 0, blob, 0, nonce.Length);
            Buffer.BlockCopy(tag, 0, blob, nonce.Length, tag.Length);
            Buffer.BlockCopy(ct, 0, blob, nonce.Length + tag.Length, ct.Length);
            return Convert.ToBase64String(blob);
        }

        public string Decrypt(string b64blob)
        {
            var blob = Convert.FromBase64String(b64blob);
            var nonce = blob.AsSpan(0, 12).ToArray();
            var tag = blob.AsSpan(12, 16).ToArray();
            var ct = blob.AsSpan(28).ToArray();
            using var aes = new AesGcm(_key);
            var pt = new byte[ct.Length];
            aes.Decrypt(nonce, ct, tag, pt);
            return Encoding.UTF8.GetString(pt);
        }
    }
}
