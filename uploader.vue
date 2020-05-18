/* eslint-disable no-use-before-define */
/* eslint-disable require-await */
<template>
  <div>
    <!-- <el-button slot="trigger" size="small" type="primary" @click="getCookie">
      获取cookie
    </el-button>
    <el-upload
      ref="upload"
      class="upload-demo"
      action="http://127.0.0.1:8080/upload/multiple"
      :on-preview="handlePreview"
      :on-remove="handleRemove"
      :before-remove="beforeRemove"
      multiple
      :limit="3"
      :on-exceed="handleExceed"
      :file-list="fileList"
      :on-success="handleSuccess"
      :auto-upload="false"
      :on-progress="handleProgress"
    >
      <el-button slot="trigger" size="small" type="primary">
        选取文件
      </el-button>
      <el-button
        style="margin-left: 10px;"
        size="small"
        type="success"
        @click="submitUpload"
      >
        上传到服务器
      </el-button>
    </el-upload>
    <div>
      <el-button slot="trigger" size="small" type="primary" @click="download">
        下载文件
      </el-button>
    </div> -->
    <div>
      <h1>表单文件上传</h1>
      <form>
        <input id="fileUpload" type="file" multiple @change="uploadFile">
        <input id="folderUpload" type="file" multiple webkitdirectory @change="uploadFolder">
      </form>
    </div>
    <div>
      <div v-for="(file, i) in uploadList" :key="i" class="upload-file">
        <div>
          <div>{{ file.name }} {{ file.status }}</div>
          <div class="icons">
            <i v-show="file.paused" class="far fa-pause-circle" @click="pause(file, false)" />
            <i v-show="!file.paused" class="far fa-play-circle" @click="pause(file, true)" />
          </div>
          <el-progress :percentage="file.percentage" color="#f56c6c" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import SparkMD5 from 'spark-md5'
export default {
  data () {
    return {
      uploadList: [],
      uploadQueue: [],
      chunkSize: 1024 * 1024 * 5,
      parallel: 3,
      start: 0
    }
  },
  methods: {
    uploadFile () {
      const files = document.getElementById('fileUpload').files
      const curLen = this.uploadList.length
      for (let i = 0; i < files.length; ++i) {
        files[i].percentage = 0
        files[i].status = '正在准备上传...'
        files[i].index = curLen + i
        this.uploadList.push(files[i])
        this.uploadQueue.push(files[i].index)
      }
      for (let i = 0; i < this.parallel; ++i) {
        this.uploadHepler()
      }
    },
    uploadHepler () {
      if (this.uploadQueue.length > 0) {
        this.computeMD5(this.uploadList[this.uploadQueue.shift()])
      }
    },
    uploadFolder () {
      const folder = document.getElementById('folderUpload').files
      console.log(folder)
    },
    // eslint-disable-next-line require-await
    computeMD5 (file) {
      this.updateObject(file, 'status', '正在计算md5...')
      const fileReader = new FileReader()
      // const time = new Date().getTime()
      const blobSlice = File.prototype.slice || File.prototype.mozSlice || File.prototype.webkitSlice
      let currentChunk = 0
      const chunkSize = 1024 * 1024 * 1
      const chunks = Math.ceil(file.size / chunkSize)
      const spark = new SparkMD5.ArrayBuffer()
      loadNext()

      fileReader.onload = (e) => {
        spark.append(e.target.result)
        if (currentChunk < chunks) {
          currentChunk++
          loadNext()
        } else {
          const md5 = spark.end()
          file.md5 = md5
          this.checkChunk(file, md5)
        }
      }
      fileReader.onerror = function () {
        console.log('计算出错')
      }
      function loadNext () {
        const start = currentChunk * chunkSize
        const end = ((start + chunkSize) >= file.size) ? file.size : start + chunkSize
        fileReader.readAsArrayBuffer(blobSlice.call(file, start, end))
      }
    },
    async checkChunk (file, md5) {
      this.updateObject(file, 'status', '正在获取分片信息')
      const data = new FormData()
      data.append('identifier', md5)
      data.append('totalSize', file.size)
      const url = '/api/chunk/check'
      await this.$axios.post(url, data).then((res) => {
        const status = res.data.status
        const ids = res.data.ids
        file.status = status
        file.ids = ids
        this.updateObject(file)
        if (status === 'success') {
          this.updateObject(file, 'percentage', 100)
          this.updateObject(file, 'status', '完成')
          this.uploadHepler()
        } else {
          this.upload(file)
        }
      }).catch(() => {
        file.ids = []
        this.upload(file)
      })
    },
    async upload (file) {
      this.updateObject(file, 'status', '正在上传...')
      const url = '/api/chunk/upload/'
      const blobSlice = File.prototype.slice || File.prototype.mozSlice || File.prototype.webkitSlice
      let start, end
      const size = this.chunkSize
      const chunks = Math.ceil(file.size / size)
      file.uploaded = file.ids.length
      const f = file
      for (let i = 0; i < chunks && !file.paused; ++i) {
        // 如果当前Chunk ID不存在, 才上传
        console.log(i, file.ids, file.ids.includes(i))
        if (!file.ids.includes(i)) {
          const data = new FormData()
          data.append('identifier', file.md5)
          data.append('filename', file.name)
          data.append('totalChunks', chunks)
          data.append('totalSize', file.size)
          data.append('chunkSize', size)
          data.append('id', file.md5 + '-' + i)
          start = i * size
          end = start + size
          if (end > f.size) {
            end = f.size
          }
          data.append('chunkNumber', i)
          data.append('currentChunkSize', end - start)
          const fslice = blobSlice.call(file, start, end)
          data.append('file', fslice)
          // 异步请求
          await this.$axios.post(url, data).then((res) => {
            file.uploaded += 1
            let percentage = Math.ceil(((file.uploaded + 1) / chunks) * 100)
            percentage = percentage <= 100 ? percentage : 100
            this.updateObject(file, 'percentage', percentage)
          }).catch(() => {
            file.status = 'error'
          })

          if (file.status === 'error') {
            this.uploadHepler()
            return
          }
        }
        if (file.uploaded === chunks) {
          this.updateObject(file, 'status', '正在合并分块')
          this.merge(file)
        }
      }
    },
    merge (file) {
      const fileInfo = new FormData()
      fileInfo.append('fileName', file.name)
      fileInfo.append('identifier', file.md5)
      fileInfo.append('totalSize', file.size)
      fileInfo.append('type', file.type)
      fileInfo.append('location', '')
      this.$axios.post('/api/chunk/merge', fileInfo).then(() => {
        this.updateObject(file, 'status', '完成')
        this.uploadHepler()
      }).catch(() => {
        this.uploadHepler()
      })
    },
    updateObject (file, key, value) {
      // vm.$set(vm.items, indexOfItem, newValue)
      if (key && value) {
        file[key] = value
      }
      this.$set(this.uploadList, file.index, file)
    },
    download () {
      this.$axios({
        url: 'http://127.0.0.1:8080/download',
        method: 'post',
        headers: {
          'Content-Range': '0-1023'
        }
      })
        .then((res) => {
          const blob = new Blob([res.data], { type: 'application/octet-stream' })
          console.log(blob.size)
          // const reader = new FileReader()
          // reader.readAsDataURL(blob)
          // reader.onload = (e) => {
          //   const a = document.createElement('a')
          //   a.download = 'ShadowsocksR-win-4.9.0.zip'
          //   a.href = e.target.result
          //   document.body.appendChild(a)
          //   a.click()
          //   document.body.removeChild(a)
          // }
        })
    },
    getCookie () {
      this.$axios.get('/api/cookie')
    },
    pause (file, flag) {
      file.paused = flag
      if (flag) {
        this.updateObject(file, 'status', '暂停中')
      } else {
        this.checkChunk(file, file.md5)
      }
    }
  }
}
</script>

<style>
.upload-file {
  width: 40%;
  height: 400px;
  overflow-y: auto;
}
.icons {
  height: 100px;
  font-size: 20px;
  text-align: center;
  line-height: 100px;
}
</style>
